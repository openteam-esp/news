class Entry < ActiveRecord::Base
  STALE_PERIOD = 1.month

  attr_accessible :title, :body, :since, :channel_ids, :annotation,
    :source, :source_link, :source_target,
    :images_attributes, :author, :event_entry_properties_attributes

  attr_accessor :current_user

  belongs_to :initiator, class_name: 'User'
  belongs_to :deleted_by, class_name: 'User'

  has_and_belongs_to_many :channels, conditions: { deleted_at: nil }, uniq: true

  has_many :events, dependent: :delete_all
  has_many :tasks,  dependent: :delete_all
  has_many :locks,  dependent: :delete_all

  has_many :images, dependent: :delete_all
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  has_many :event_entry_properties, foreign_key: :entry_id, dependent: :delete_all
  accepts_nested_attributes_for :event_entry_properties, allow_destroy: true

  has_one :prepare
  has_one :review
  has_one :publish

  validates_presence_of :current_user
  validates_presence_of :channels, on: :update

  extend FriendlyId
  friendly_id :truncated_title, use: :slugged

  def should_generate_new_friendly_id?
    slug.blank? && title.present?
  end

  extend Enumerize
  enumerize :source_target, in: [:current, :new_tab], predicates: true

  state_machine initial: :draft do
    state :draft
    state :correcting
    state :publishing
    state :published do
      validates_presence_of :title, :since
      validates_presence_of :actuality_expired_at, if: :is_announce?
      validates_presence_of :body, unless: :is_youtube?
    end

    before_transition publishing: :published, do: :set_since

    after_transition publishing: :published, do: :send_publish_message

    after_transition published: :publishing, do: :send_unpublish_message

    event :up do
      transition draft: :correcting, correcting: :publishing, publishing: :published
    end

    event :down do
      transition published: :publishing, publishing: :correcting, correcting: :draft
    end
  end

  scope :by_state, ->(state) { where(state: state) }

  scope :deleted, where('deleted_by_id IS NOT NULL')
  scope :not_deleted, where(deleted_by_id: nil)
  scope :initiated_by, ->(user) { where(initiator_id: user) }
  scope :processing, -> { where(state: processing_states).not_deleted }
  scope :published, -> { where(state: :published).not_deleted }
  scope :draft, -> { where(state: :draft).not_deleted }
  scope :stale, -> { deleted.where('deleted_at <= ?', STALE_PERIOD.ago) }
  scope :since_greater_than, ->(date) { where('since >= ?', date) }

  def self.folder(folder, user)
    case folder.to_sym
    when :processing  then user.initiator? ? processing.initiated_by(user) : processing
    when :draft       then draft.initiated_by(user)
    when :published   then published
    when :deleted     then where(deleted_by_id: user)
    end
      .joins(:channels).where("channels.id IN (#{Channel.subtree_for(user).select(:id).to_sql})")
      .order('id desc')
      .uniq
  end

  before_create :set_initiator

  after_create :create_tasks
  after_create :create_event

  default_value_for :vfs_path do
    generate_vfs_path
  end

  searchable(include: [:channels, :event_entry_properties]) do
    string(:deleted_state) { deleted? ? 'deleted' : 'not_deleted' }
    integer :channel_ids, multiple: true do channels.map(&:id).uniq end
    text :title, boost: 3.0, more_like_this: true
    text :annotation, boost: 2.0, more_like_this: true do
      annotation.to_s.strip_html
    end
    text :body, boost: 1.0, more_like_this: true do
      body.to_s.strip_html
    end
    string :state
    time   :since
    time :event_entry_properties_since do
      event_entry_properties.first.try(:since)
    end
    time :event_entry_properties_until do
      event_entry_properties.last.try :until
    end
    time :actuality_expired_at
  end

  alias_method :sunspot_more_like_this, :more_like_this

  attr_accessor :more_like_this

  normalize_attribute :title, with: [:squish, :blank]
  normalize_attribute :annotation, with: [:sanitize, :strip, :blank]
  normalize_attribute :body, with: [:sanitize, :strip, :blank]

  audited

  def issues
    [prepare, review, publish]
  end

  def generate_vfs_path
    Entry.generate_vfs_path
  end

  def self.generate_vfs_path
    "/news/#{Time.now.strftime('%Y/%m/%d/%H-%M')}-#{SecureRandom.hex(4)}"
  end

  def truncated_title
    return nil unless title
    %[#{self.class.model_name.human} #{title.truncate(100, ommission: '', separator: ' ')}]
  end

  def processing_issue
    issues.select(&:processing?).first
  end

  def self.all_states
    @all_states ||= state_machine.states.map(&:name)
  end

  def self.shared_states
    all_states - owned_states
  end

  def self.owned_states
    ['draft']
  end

  def self.processing_states
    [:correcting, :publishing]
  end

  def self.non_published_states
    all_states - [:published]
  end

  def lock
    locks.create! user: current_user unless locked?
  end

  def locked?
    self.locks.any?
  end

  def unlock
    locks.destroy_all
  end

  def locked_by
    locks.first.try :user
  end

  def locked_at
    locks.first.try :created_at
  end

  def move_to_trash
    transaction do
      update_column :deleted_by_id, current_user.id
      update_column :deleted_at, DateTime.now
    end
    index!
  end

  def revivify
    transaction do
      update_column :deleted_by_id, nil
      update_column :deleted_at, nil
    end
    index!
  end

  def has_processing_task_executed_by?(user)
    tasks.processing.where(executor_id: user).exists?
  end

  def has_participant?(user)
    tasks.where(['executor_id = ? OR initiator_id = ?', user, user]).exists?
  end

  def as_json(options={})
    methods = [*options[:methods]] + [:more_like_this, :images, :thumbnail] - [*options[:except]]
    super options.merge(only: [:annotation, :author, :body, :since, :updated_at, :slug, :source, :source_link, :source_target, :title, :type],
                        methods: methods)
  end

  def find_more_like_this(options)
    if options[:count].to_i > 0
      self.more_like_this = self.sunspot_more_like_this do
        boost_by_relevance          true
        maximum_query_terms         50
        minimum_document_frequency  2
        minimum_term_frequency      1
        minimum_word_length         3
        with(:state, :published)
        with(:since).greater_than(options[:months].to_i.month.ago)
        with(:deleted_state, 'not_deleted')
        with(:channel_ids, options[:channel_id]) if options[:channel_id]
        paginate per_page: options[:count].to_i
      end.results

      self.more_like_this.each do |entry|
        entry.images.each do |image|
          image.create_thumbnail(options.slice(:width, :height))
        end
      end
    end
  end

  def message_for_queue
    { slug: slug, channel_ids: channels.map(&:id) }
  end

  def is_announce?
    false
  end

  def is_youtube?
    false
  end

  def deleted?
    !!deleted_at
  end

  alias_method :deleted, :deleted?

  def set_current_user(current_user)
    self.current_user = current_user
    if persisted?
      prepare.current_user = current_user
      review.current_user = current_user
      publish.current_user = current_user
    end
  end

  def will_be_destroyed_at
    deleted_at + STALE_PERIOD
  end

  def prefix
    "regular_entry"
  end

  private

  def create_tasks
    create_prepare!({ current_user: current_user }, without_protection: true)
    create_review!({ current_user: current_user }, without_protection: true)
    create_publish!({ current_user: current_user }, without_protection: true)
  end

  def create_event
    events.create! event: 'accept', task: prepare, user: current_user
  end

  def set_since
    self.since ||= Time.now
  end

  def send_publish_message
    MessageMaker.make_message 'esp.news.cms', 'publish', message_for_queue
  end

  def send_unpublish_message
    MessageMaker.make_message 'esp.news.cms', 'remove', message_for_queue
  end

  def set_initiator
    self.initiator = current_user
  end
end

# == Schema Information
#
# Table name: entries
#
#  id                   :integer          not null, primary key
#  deleted_at           :datetime
#  since                :datetime
#  deleted_by_id        :integer
#  initiator_id         :integer
#  legacy_id            :integer
#  author               :string(255)
#  slug                 :string(255)
#  state                :string(255)
#  vfs_path             :string(255)
#  annotation           :text
#  body                 :text
#  title                :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  source               :text
#  source_link          :text
#  type                 :string(255)
#  actuality_expired_at :datetime
#  youtube_code         :string(255)
#  source_target        :string(255)
#
