# encoding: utf-8

class Entry < ActiveRecord::Base

  attr_accessor :dirty

  belongs_to :initiator, :class_name => 'User'
  belongs_to :folder

  has_and_belongs_to_many :channels

  has_many :events, :validate => false

  has_many :assets

  accepts_nested_attributes_for :assets, :reject_if => :all_blank, :allow_destroy => true

  has_many :attachments
  has_many :audios
  has_many :images
  has_many :videos

  default_scope order('created_at desc')

  scope :published, where(:state => 'published')
  scope :trash, where(:state => 'trash')

  after_create :create_subscribe

  default_value_for :initiator_id do User.current_id end

  default_value_for :folder_id do Folder.draft.try(:id) end

  state_machine :initial => :draft do
    after_transition :to => :correcting do |entry, transition|
      entry.folder = Folder.where(:title => 'correcting').first
      entry.save!
    end

    after_transition :to => :draft do |entry, transition|
      entry.folder = Folder.where(:title => 'draft').first
      entry.save!
    end

    after_transition :to => :published do |entry, transition|
      entry.folder = Folder.where(:title => 'published').first
      entry.save!
      entry.send_by_email
    end

    after_transition :trash => :draft do |entry, transition|
      entry.initiator_id = User.current
      entry.save!
    end

    after_transition :to => :trash do |entry, transition|
      entry.folder = Folder.where(:title => 'trash').first
      entry.save!
    end

    after_transition :to => :awaiting_correction do |entry, transition|
      entry.folder = Folder.where(:title => 'awaiting_correction').first
      entry.save!
    end

    after_transition :to => :awaiting_publication do |entry, transition|
      entry.folder = Folder.where(:title => 'awaiting_publication').first
      entry.save!
    end

    event :store

    event :correct do
      transition :awaiting_correction => :correcting
    end

    event :immediately_publish do
      transition :draft => :published
    end

    event :immediately_send_to_publisher do
      transition :draft => :awaiting_publication
    end

    event :publish do
      transition [:awaiting_publication, :correcting] => :published
    end

    event :restore do
      transition :trash => :draft
    end

    event :return_to_author do
      transition :awaiting_correction => :draft
    end

    event :return_to_corrector do
      transition [:awaiting_publication, :published] => :awaiting_correction
    end

    event :send_to_corrector do
      transition :draft => :awaiting_correction
    end

    event :send_to_publisher do
      transition :correcting => :awaiting_publication
    end

    event :to_trash do
      transition [:awaiting_publication, :awaiting_correction, :correcting, :draft, :published] => :trash
    end
  end

  def created_human
    result = "Создано "
    result += ::I18n.l(self.created_at, :format => :long)
  end

  def self.filter_for(user, folder)
    return where(:initiator_id => user.id) if user.roles.nil? || folder == 'draft'
    return includes(:events).where('events.user_id' => user.id) if folder == 'trash'
    return scoped
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
    [ presented(:title).truncate(80, :omission => '…'),
      presented?(:body, :html => true) ].
        compact.join(' – ').truncate(100, :omission => '…')
  end

  def state_events_for_author(user)
    return [] if initiator != user
    state_events & [:send_to_corrector, :to_trash, :restore]
  end

  def state_events_for_corrector(user)
    result = state_events & [:return_to_author, :correct, :restore, :send_to_publisher]
    result << :immediately_send_to_publisher if draft? && initiator == user
    result << :to_trash if awaiting_correction? || (draft? && initiator == user) || correcting?
    result
  end

  def state_events_for_publisher(user)
    result = state_events & [:return_to_corrector, :publish, :restore, :send_to_corrector]
    result << :to_trash if awaiting_publication? || (draft? && initiator == user) || published?
    result
  end

  def state_events_for_corrector_and_publisher(user)
    result = state_events & [:correct, :immediately_publish, :publish, :restore, :return_to_author, :return_to_corrector, :to_trash]
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

  def changed?
    dirty || super
  end

  private

    def create_update_event
      events.create! :kind => 'updated'  if content_attributes_changed?
      self.dirty = false
    end

    def content_attributes_changed?
      self.dirty || (changes.keys - %w[state updated_at folder_id]).any?
    end

    def make_dirty(*args)
      self.dirty = true
    end

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
#  deleted        :boolean
#  author         :string(255)
#  initiator_id   :integer
#  folder_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  old_id         :integer
#  old_channel_id :integer
#

