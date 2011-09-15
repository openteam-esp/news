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
  has_many :tasks, :dependent => :destroy

  has_one :prepare
  has_one :review
  has_one :publish

  has_enum :state, %w[draft correcting publishing published]

  default_scope order('created_at desc')

  scope :self_initiated, lambda { where(:initiator_id => User.current_id) }

  scope :by_state, lambda { |state|
    if state.to_s == 'processing'
      where(:state => processing_states)
    else
      where(:state => state)
    end
  }

  scope :state, lambda { |state|
    if User.current.roles.empty? || state.to_s == 'draft'
      by_state(state).self_initiated
    else
      by_state(state)
    end
  }

  after_create :create_subscribe, :create_tasks

  accepts_nested_attributes_for :assets, :reject_if => :all_blank, :allow_destroy => true

  default_value_for :initiator do User.current end
  default_value_for :state, :draft

  searchable do
    text   :title,      :boost => 3.0
    text   :annotation, :boost => 2.0
    text   :body,       :boost => 1.0
    date   :since
    date   :until
    string :state

    integer :channel_ids, :multiple => true do
      channel_ids
    end
  end

  def current_user
    User.current
  end

  def self.all_states
    enums[:state]
  end

  def self.shared_states
    all_states - owned_states
  end

  def self.owned_states
    ['draft']
  end

  def self.processing_states
    %w[correcting publishing]
  end

  delegate :publisher?, :corrector?, :to => :current_user, :prefix => true

  def current_user_initiator?
    initiator == current_user
  end

  def current_user_participant?
    current_user_initiator? || events.where(:user_id => current_user).any?
  end

  def current_user_is_a?(*args)
    args.map{|role| self.send("current_user_#{role}?")}.uniq.compact == [true]
  end

  def created_human
    result = "Создано "
    result += ::I18n.l(self.created_at, :format => :long)
    result += " ("
    result += time_ago_in_words(self.created_at)
    result += " назад)"
  end

  def next_task(task)
    tasks[tasks.index(task) + 1]
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

    def create_tasks
      create_prepare :executor => User.current
      create_review
      create_publish
    end
end

# == Schema Information
#
# Table name: entries
#
#  id           :integer         not null, primary key
#  title        :text
#  annotation   :text
#  body         :text
#  since        :datetime
#  until        :datetime
#  state        :string(255)
#  author       :string(255)
#  initiator_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  legacy_id    :integer
#

