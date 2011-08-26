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

  scope :published, where(:state => :published)

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

  def current_user
    User.current
  end

  delegate :publisher?, :corrector?, :to => :current_user, :prefix => true

  def current_user_initiator?
    initiator == current_user
  end

  def current_user_participant?
    current_user_initiator? || events.where(:user_id => current_user.id).any?
  end

  def current_user_is_a?(*args)
    args.map{|role| self.send("current_user_#{role}?")}.uniq.compact == [true]
  end

  state_machine :initial => :draft do
    after_transition :to => :published do |entry, transition|
      entry.send_by_email
    end

    event :recover do
      transition :trash => :draft, :if => :current_user_participant?
    end

    event :publish do
      transition :draft => :published, :if => ->(entry) { entry.current_user_is_a? :initiator, :publisher}
      transition :correcting => :published, :if => ->(entry) { entry.current_user_is_a? :initiator, :corrector, :publisher }
      transition :publicating => :published, :if => :current_user_publisher?
    end

    event :request_publicating do
      transition :draft => :awaiting_publication, :if => ->(entry) { entry.current_user_is_a? :initiator, :corrector}
      transition :correcting => :awaiting_publication, :if => :current_user_corrector?
    end

    event :accept_publicating do
      transition :trash => :publicating, :if => ->(entry) { entry.current_user_is_a? :participant, :publisher  }
      transition :awaiting_publication => :publicating, :if => :current_user_publisher?
    end

    event :request_correcting do
      transition :draft => :awaiting_correction, :if => :current_user_initiator?
    end

    event :store do
      transition :draft => :draft, :if => :current_user_initiator?
      transition :correcting => :correcting, :if => :current_user_corrector?
      transition :publicating => :publicating, :if => :current_user_publisher?
      transition :published => :published, :if => :current_user_publisher?
    end

    event :request_correcting do
      transition [:awaiting_publication, :publicating] => :awaiting_correction, :if => :current_user_publisher?
    end

    event :restore

    event :accept_correcting do
      transition :trash => :correcting, :if => ->(entry) { entry.current_user_is_a? :corrector, :participant }
      transition [:awaiting_correction, :awaiting_publication] => :correcting, :if => :current_user_corrector?
    end

    event :request_reworking do
      transition :awaiting_correction => :draft, :if => ->(entry) {entry.current_user_initiator? || entry.current_user_corrector?}
      transition :correcting => :draft, :if => :current_user_corrector?
    end

    event :discard do
      transition [:draft, :awaiting_correction] => :trash, :if => :current_user_initiator?
      transition [:awaiting_correction, :correcting, :awaiting_publication] => :trash, :if => :current_user_corrector?
      transition [:awaiting_publication, :publicating, :published] => :trash, :if => :current_user_publisher?
    end

  end

  def permitted_events
    state_events.select{ |event| self.class.state_machine.events[event.to_sym].can_fire?(self) }
  end

  def self.all_states
    state_machine.states.map(&:name)
  end

  def self.owned_states
    [:draft, :trash, :published]
  end

  def self.shared_states
    all_states - owned_states
  end

  def self.all_events
    state_machine.events.map(&:name)
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

