# encoding: utf-8

class Entry < ActiveRecord::Base

  attr_accessor :current_user

  extend FriendlyId

  belongs_to :initiator, :class_name => 'User'
  belongs_to :locked_by, :class_name => 'User'
  belongs_to :deleted_by, :class_name => 'User'

  has_and_belongs_to_many :channels, :conditions => {:deleted_at => nil}, :uniq => true

  has_many :events, :dependent => :destroy
  has_many :tasks, :dependent => :destroy

  has_one :prepare
  has_one :review
  has_one :publish

  attr_accessor :locking

  validates_presence_of :initiator

  after_validation :unlock, :if => :need_unlock?

  friendly_id :truncated_title, :use => :slugged

  state_machine :initial => :draft do
    state :draft
    state :correcting
    state :publishing
    state :published do
      validates_presence_of :title, :body, :channels, :since
    end

    before_transition :publishing => :published, :do => :set_since

    event :up do
      transition :draft => :correcting, :correcting => :publishing, :publishing => :published
    end

    event :down do
      transition :published => :publishing, :publishing => :correcting, :correcting => :draft
    end
  end

  scope :not_deleted, where(:deleted_by_id => nil)
  scope :descending, ->(attribute) { order("#{attribute} desc") }
  scope :initiated_by, ->(user) { where(:initiator_id => user) }
  scope :processing, -> { where(:state => processing_states).not_deleted }
  scope :published, -> { where(:state => :published).not_deleted.descending(:since) }
  scope :draft, -> { where(:state => :draft).not_deleted }
  scope :stale, -> { where("delete_at >= '#{Time.now}'") }

  def self.folder(folder, user)
    case folder.to_sym
    when :processing  then user.have_permissions? ? processing : processing.initiated_by(user)
    when :draft       then draft.initiated_by(user)
    when :deleted     then where(:deleted_by_id => user)
    end.descending(:id)
  end

  def truncated_title
    title.split(/\s+/)[0..4].compact.join(' ') if title
  end

  def processing_issue
    issues.select(&:processing?).first
  end

  after_create :create_tasks
  after_create :create_event

  default_value_for :vfs_path do
    "/news/#{Time.now.strftime('%Y/%m/%d/%H-%M')}-#{SecureRandom.hex(4)}"
  end

  searchable do
    text   :title,      :boost => 3.0
    text   :annotation, :boost => 2.0
    text   :body,       :boost => 1.0
    date   :since
    date   :updated_at
    string :state
    integer :channel_ids, :multiple => true do channels.map(&:id).uniq end
  end

  normalize_attribute :title, :with => [:squish, :gilensize_as_text, :blank]
  normalize_attribute :annotation, :body, :with => [:sanitize, :gilensize_as_html, :strip, :blank]

  def issues
    [prepare, review, publish]
  end

  def self.all_states
    state_machine.states.map(&:name)
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

  def lock
    self.locking = true
    update_attributes! :locked_at => DateTime.now, :locked_by => current_user
  end

  def locked?
    self.locked_at?
  end

  def need_unlock?
    !self.locking && self.locked?
  end

  def unlock
    update_attributes :locked_at => nil, :locked_by => nil
  end

  def deleted?
    deleted_by_id
  end

  def move_to_trash
    self.tap do | entry |
      entry.update_attributes :deleted_by => current_user, :delete_at => Time.now + 1.month
      entry.tasks.update_all :deleted_at => Time.now
    end
  end

  def revivify
    self.tap do | entry |
      entry.update_attributes :deleted_by => nil, :delete_at => nil
      entry.tasks.update_all :deleted_at => nil
    end
  end

  def has_processing_task_executed_by?(user)
    tasks.processing.where(:executor_id => user).exists?
  end

  def has_participant?(user)
    tasks.where(['executor_id = ? OR initiator_id = ?', user, user]).exists?
  end

  def as_json(options={})
    super(options.merge(:only => [:annotation, :author, :body, :slug, :title, :updated_at]))
  end

  def resized_image_url(options)
    @resized_image_url ||= begin
                             width = options[:width]
                             height = options[:height]

                             dimentions = image_dimentions(file_url)
                             ar = dimentions[:width].to_f / dimentions[:height].to_f

                             if ar > 1
                               height = (width / ar).to_i
                             else
                               width = (height * ar).to_i
                             end

                             file_url.gsub(%r{files/(\d+)/([\d-]+)/}, "files/\\1/#{width}-#{height}/")
                           end
  end


  def image_dimentions(url)
    width, height = url.match(%r{files/\d+/(\d+)-(\d+)})[1..2]
    {:width => width, :height => height}
  end

  private

    def create_tasks
      create_prepare :initiator => initiator, :entry => self, :executor => initiator
      create_review :initiator => initiator, :entry => self
      create_publish :initiator => initiator, :entry => self
    end

    def create_event
      events.create! :event => 'accept', :task => prepare, :user => current_user
    end

    def set_since
      self.since ||= Time.now
    end

end







# == Schema Information
#
# Table name: entries
#
#  id            :integer         not null, primary key
#  delete_at     :datetime
#  locked_at     :datetime
#  since         :datetime
#  deleted_by_id :integer
#  initiator_id  :integer
#  legacy_id     :integer
#  locked_by_id  :integer
#  author        :string(255)
#  slug          :string(255)
#  state         :string(255)
#  vfs_path      :string(255)
#  file_url      :string(255)
#  annotation    :text
#  body          :text
#  title         :text
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

