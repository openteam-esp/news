class Entry
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  field :title,         :type => String
  field :annotation,    :type => String
  field :body,          :type => String
  field :since,         :type => DateTime
  field :until,         :type => DateTime
  field :state,         :type => String
  field :deleted,       :type => Boolean, :default => false
  field :author,        :type => String,  :default => ::I18n.t('default_author')
  index :updated_at

  belongs_to :initiator, :class_name => 'User'
  belongs_to :folder

  has_and_belongs_to_many :channels

  embeds_many :events, :order => [[:created_at, :desc]], :validate => false

  attr_accessor :user_id

  scope :published, where(:state => 'published')

  validates_presence_of :body

  after_create :create_event

  after_update :create_update_event

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
      entry.initiator_id = entry.events.unscoped.where(:type => 'restore').last.id
      entry.save!
    end

    after_transition :to => :trash do |entry, transition|
      entry.folder = Folder.where(:title => 'trash').first
      entry.save!
    end

    after_transition :to => [:awaiting_correction, :awaiting_publication] do |entry, transition|
      entry.folder = Folder.where(:title => 'inbox').first
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
    return where('events.user_id' => user.id) if folder == 'trash'
    all
  end


  def related_to(user)
    events.where(:user_id => user.id).any?
  end

  def send_by_email
    mailing_channels = []
    self.channels.each do |channel|
      mailing_channels << channel if channel.recipients.any?
    end

    EntryMailer.entry_mailing(self, mailing_channels).deliver if mailing_channels.any?
  end

  def title_or_body
    title.present? ? title.truncate(100) : body.truncate(100)
  end

  def state_events_for_author(user)
    return [] if initiator != user
    state_events & [:send_to_corrector, :to_trash]
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
    def create_event
      events.create! :type => 'created', :user_id => user_id
      self.initiator_id = user_id
      self.folder = Folder.where(:title => 'draft').first
      self.save!
    end

    def create_update_event
       if previous_changes.has_key?('annotation') || previous_changes.has_key?('body') || previous_changes.has_key?('title')
         events.create! :type => 'updated', :user_id => user_id
       end
    end
end
