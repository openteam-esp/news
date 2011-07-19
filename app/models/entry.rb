class Entry
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  field :title,       :type => String
  field :annotation,  :type => String
  field :body,        :type => String
  field :since,       :type => DateTime
  field :until,       :type => DateTime
  field :state,       :type => String
  field :deleted,     :type => Boolean, :default => false
  field :author,      :type => String,  :default => ::I18n.t('default_author')

  belongs_to :folder

  has_and_belongs_to_many :channels

  has_many :events

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
      transition :awaiting_publication => :published
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
      transition [:awaiting_publication, :awaiting_correction, :draft] => :trash
    end
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

  def state_events_for_author
    state_events & [:send_to_corrector, :to_trash]
  end

  def state_events_for_corrector
    result = state_events & [:return_to_author, :correct, :send_to_publisher]
    result << :immediately_send_to_publisher if draft?
    result << :to_trash if awaiting_correction?
    result
  end

  def state_events_for_publisher
    result = state_events & [:return_to_corrector, :publish]
    result << :immediately_publish if draft?
    result << :to_trash if awaiting_publication?
    result
  end

  def state_events_for_user(user)
    return state_events_for_author if !user.corrector? && !user.publisher?

    result = []
    result << state_events_for_corrector if user.corrector?
    result << state_events_for_publisher if user.publisher?
    result.flatten.uniq.sort
  end

  # TODO: разобраться с корзиной

  private
    def create_event
      events.create! :type => 'created', :user_id => user_id
      self.folder = Folder.where(:title => 'draft').first
      self.save!
    end

    def create_update_event
       if previous_changes.has_key?('annotation') || previous_changes.has_key?('body') || previous_changes.has_key?('title')
         events.create! :type => 'updated', :user_id => user_id
       end
    end
end
