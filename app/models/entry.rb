# encoding: utf-8

include ActionView::Helpers::DateHelper

class Entry < ActiveRecord::Base

  belongs_to :initiator, :class_name => 'User'

  has_and_belongs_to_many :channels, :conditions => {:deleted_at => nil}

  has_many :events, :validate => false

  has_many :assets, :conditions => {:deleted_at => nil}

  has_many :attachments, :conditions => {:deleted_at => nil}
  has_many :audios, :conditions => {:deleted_at => nil}
  has_many :images, :conditions => {:deleted_at => nil}
  has_many :videos, :conditions => {:deleted_at => nil}

  default_scope order('created_at desc')

  scope :published, where(:state => 'published')

  scope :by_state, lambda { |state| where(:state => state) }
  scope :self_initiated, lambda { where(:initiator_id => User.current_id) }

  scope :state, lambda { |state|
    if User.current.roles.empty? || %w[draft trash published].include?(state.to_s)
      by_state(state).self_initiated
    else
      by_state(state)
    end
  }


  after_create :create_subscribe

  accepts_nested_attributes_for :assets, :reject_if => :all_blank, :allow_destroy => true

  default_value_for :initiator_id do User.current_id end

  state_machine :initial => :draft do
    after_transition :to => :published do |entry, transition|
      entry.send_by_email
    end

    event :store

    event :restore

    event :request_correcting do
      transition [:draft, :awaiting_publication, :publicating, :published] => :awaiting_correction
    end

    event :accept_correcting do
      transition [:trash, :awaiting_correction] => :correcting
    end

    event :request_reworking do
      transition [:awaiting_correction, :correcting] => :draft
    end

    event :request_publicating do
      transition [:correcting, :draft] => :awaiting_publication
    end

    event :accept_publicating do
      transition [:trash, :awaiting_publication] => :publicating
    end

    event :publish do
      transition [:draft, :correcting, :publicating] => :published
    end

    event :to_trash do
      transition all - [:trash] => :trash
    end

    event :untrash do
      transition :trash => :draft
    end
  end

  def self.all_states
    self.state_machines[:state].states.map(&:name)
  end

  def self.owned_states
    [:draft, :trash, :published]
  end

  def self.shared_states
    all_states - owned_states
  end

  def self.all_events
    Entry.state_machines[:state].events.map(&:name)
  end

  def created_human
    result = "Создано "
    result += ::I18n.l(self.created_at, :format => :long)
    result += " ("
    result += time_ago_in_words(self.created_at)
    result += " назад)"
  end

  def restore(*args)
    super
    self.assets.destroy_all
    if entry = events.offset(1).first.try(:versioned_entry)
      self.update_attributes entry.attributes.merge(:channel_ids => entry.channel_ids)
      self.assets.unscoped.where(:id => entry.image_ids + entry.video_ids + entry.audio_ids + entry.attachment_ids).update_all(:deleted_at => nil)
    else
      self.update_attributes Entry.new.attributes.merge(:channel_ids => [])
    end
  end

  def related_to(user)
    events.where(:user_id => user.id).any? || initiator == user
  end

  def send_by_email
    mailing_channels = []
    self.channels.each do |channel|
      mailing_channels << channel if channel.recipients.any?
    end
    EntryMailer.delay.entry_mailing(self, mailing_channels) if mailing_channels.any?
  end

  def presented?(attribute, options={})
    value = self.send(attribute)
    presented = options[:html] ? value.try(:strip_html).presence : value.presence
  end

  def presented(attribute, options={})
    presented?(attribute, options) ? self.send(attribute) : I18n.t("blank_entry_#{attribute}")
  end

  def composed_title
    [ presented(:title).truncate(80, :omission => '…'), presented?(:body, :html => true) ].
      compact.join(' – ').truncate(100, :omission => '…')
  end

  def state_events_for_author(user)
    return [] if initiator != user
    state_events & [:send_to_corrector, :to_trash, :untrash]
  end

  def state_events_for_corrector(user)
    result = state_events & [:return_to_author, :correct, :untrash, :send_to_publisher]
    result << :immediately_send_to_publisher if draft? && initiator == user
    result << :to_trash if awaiting_correction? || (draft? && initiator == user) || correcting?
    result
  end

  def state_events_for_publisher(user)
    result = state_events & [:return_to_corrector, :publish, :untrash, :send_to_corrector]
    result << :to_trash if awaiting_publication? || (draft? && initiator == user) || published?
    result
  end

  def state_events_for_corrector_and_publisher(user)
    result = state_events & [:correct, :immediately_publish, :publish, :untrash, :return_to_author, :return_to_corrector, :to_trash]
    result << :immediately_publish if draft? && initiator == user
    result << :to_trash if draft? && initiator == user
    result
  end

  def state_events_for(user)
    return state_events_for_author(user) if !user.corrector? && !user.publisher?

    result = []
    result << state_events_for_corrector(user) if user.corrector? && user.roles.one?
    result << state_events_for_publisher(user) if user.publisher? && user.roles.one?
    result << state_events_for_corrector_and_publisher(user) if user.corrector? && user.publisher?
    result.flatten.uniq.sort
  end

  private

    def create_subscribe
      Subscribe.create!(:subscriber => initiator, :entry => self)
    end
end







# == Schema Information
#
# Table name: entries
#
#  id             :integer         not null, primary key
#  title          :text
#  annotation     :text
#  body           :text
#  since          :datetime
#  until          :datetime
#  state          :string(255)
#  author         :string(255)
#  initiator_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#  old_id         :integer
#  old_channel_id :integer
#

