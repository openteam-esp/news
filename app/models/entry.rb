# encoding: utf-8

class Entry < ActiveRecord::Base
  belongs_to :initiator, :class_name => 'User'
  belongs_to :locked_by, :class_name => 'User'
  belongs_to :deleted_by, :class_name => 'User'

  has_and_belongs_to_many :channels, :conditions => {:deleted_at => nil}

  has_many :events
  has_many :assets, :conditions => {:deleted_at => nil}
  has_many :attachments, :conditions => {:deleted_at => nil}
  has_many :audios, :conditions => {:deleted_at => nil}
  has_many :images, :conditions => {:deleted_at => nil}
  has_many :videos, :conditions => {:deleted_at => nil}
  has_many :tasks, :dependent => :destroy

  has_one :prepare
  has_one :review
  has_one :publish

  attr_accessor :locking

  after_validation :unlock, :if => :need_unlock?

  state_machine :initial => :draft do
    state :draft
    state :correcting
    state :publishing
    state :published do
      validates_presence_of :title, :body, :channels
    end

    event :up do
      transition :draft => :correcting, :correcting => :publishing, :publishing => :published
    end

    event :down do
      transition :published => :publishing, :publishing => :correcting, :correcting => :draft
    end
  end

  scope :not_deleted, where(:deleted_by_id => nil)
  scope :descending, ->(attribute) { order("#{attribute} desc") }
  scope :self_initiated, -> { where(:initiator_id => User.current_id) }
  scope :processing, -> { where(:state => processing_states).not_deleted }
  scope :published, -> { where(:state => :published).not_deleted.descending(:since) }
  scope :draft, -> { where(:state => :draft).not_deleted }

  def self.folder(folder)
    case folder.to_sym
    when :processing  then User.current.roles.any? ? processing : processing.self_initiated
    when :draft       then draft.self_initiated
    when :deleted     then where(:deleted_by_id => User.current_id)
    end.descending(:id)
  end


  after_create :create_tasks
  after_create :create_event

  after_update :create_event_at_update

  accepts_nested_attributes_for :assets, :reject_if => :all_blank, :allow_destroy => true

  default_value_for :initiator do User.current end

  searchable do
    text   :title,      :boost => 3.0
    text   :annotation, :boost => 2.0
    text   :body,       :boost => 1.0
    date   :since
    date   :until
    string :state
    integer :channel_ids, :multiple => true
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
    update_attributes! :locked_at => DateTime.now, :locked_by => User.current
  end

  def locked?
    self.locked_at?
  end

  def need_unlock?
    !self.locking && self.locked?
  end

  def unlock
    self.locked_at = nil
    self.locked_by = nil
  end

  def deleted?
    deleted_by_id
  end

  alias :destroy_without_trash :destroy

  def destroy
    self.tap do | entry |
      entry.update_attribute :deleted_by, User.current
      entry.tasks.update_all(:deleted_at => Time.now)
    end
  end

  def recycle
    self.tap do | entry |
      entry.update_attribute :deleted_by, nil
      entry.tasks.update_all(:deleted_at => nil)
    end
  end

  def has_processing_task_executed_by?(user)
    tasks.processing.where(:executor_id => user).exists?
  end

  def has_participant?(user)
    tasks.where(['executor_id = ? OR initiator_id = ?', self, self]).exists?
  end


  private
    def create_tasks
      create_prepare :initiator => initiator, :entry => self, :executor => initiator
      create_review :initiator => initiator, :entry => self
      create_publish :initiator => initiator, :entry => self
    end

    def create_event
      events.create :kind => 'create_entry'
    end

    def create_event_at_update
      events.create :kind => 'update_entry', :entry => self unless state_changed?
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
#  locked_at    :datetime
#  locked_by_id :integer
#  deleted_at   :datetime
#

