class Entry < ActiveRecord::Base
  belongs_to :initiator, :class_name => 'User'
  belongs_to :folder

  has_and_belongs_to_many :channels

  has_many :events, :validate => false

  attr_accessor :user_id

  scope :published, where(:state => 'published')
  scope :trash, where(:state => 'trash')

  validates_presence_of :body

  after_create :set_initiator_and_folder, :create_subscribe, :create_event

  after_update :create_update_event

  has_paper_trail

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
      entry.initiator_id = entry.events.unscoped.where(:kind => 'restore').last.user_id
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

  def self.filter_for(user, folder)
    return where(:initiator_id => user.id) if user.roles.nil? || folder == 'draft'
    return includes(:events).where('events.user_id' => user.id) if folder == 'trash'
    return scoped
  end

  def related_to(user)
    events.where(:user_id => user.id).any?
  end

  def send_by_email
    mailing_channels = []
    self.channels.each do |channel|
      mailing_channels << channel if channel.recipients.any?
    end

    EntryMailer.delay.entry_mailing(self, mailing_channels) if mailing_channels.any?
  end

  def title_or_body
    title.present? ? title.truncate(100) : body.truncate(100)
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

  private
    def set_initiator_and_folder
      self.initiator_id = user_id
      self.folder = Folder.where(:title => 'draft').first
      self.class.skip_callback(:update, :after, :create_update_event)
      self.save(:skip_callbacks => false)
      self.class.set_callback(:update, :after, :create_update_event)
    end

    def create_event
      events.create! :kind => 'created', :user_id => user_id
    end

    def create_update_event
      %w[annotation body since title until].each do |key|
        if changes.has_key?(key)
          events.create! :kind => 'updated', :user_id => user_id and break
        end
      end
    end

    def create_subscribe
      Subscribe.create!(:subscriber => initiator, :entry => self)
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
#  deleted      :boolean
#  author       :string(255)
#  initiator_id :integer
#  folder_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#

