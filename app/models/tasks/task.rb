# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  entry_id     :integer
#  executor_id  :integer
#  initiator_id :integer
#  issue_id     :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Task < ActiveRecord::Base
  attr_accessor :current_user

  attr_accessible :comment, :state_event

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'

  before_create :set_initiator

  validates_presence_of :current_user

  scope :ordered, order('id desc')
  scope :not_deleted, where(:deleted_at => nil)
  scope :processing, where(:state => :processing)

  scope :folder, ->(folder, user) { send folder, user }
  scope :fresh, ->(user) do
    types = ['Subtask']
    types << 'Review' if user.corrector?
    types << 'Publish' if user.publisher?
    Task.not_deleted.where(:type => types).where(:state => :fresh).where(['executor_id IS NULL OR executor_id = ?', user])
  end
  scope :processed_by_me, ->(user) do
    Task.not_deleted.processing.where(:executor_id => user)
  end
  scope :initiated_by_me, ->(user) do
    Task.not_deleted.where(:initiator_id => user).where("state <> 'pending'")
  end

  default_scope ordered

  delegate :prepare, :review, :publish, :to => :entry
  delegate :fresh?, :to => :next_task, :prefix => true

  def deleted?
    deleted_at
  end

  def self.human_state_events
    [:accept, :complete, :restore, :refuse]
  end

  def human_state_events
    self.class.human_state_events & state_events
  end

  def next_task
  end

  protected

  def create_event(transition)
    entry.events.create! :entry => entry, :task => self, :event => transition.event.to_s, :user => current_user if self.class.human_state_events.include? transition.event
  end

  def set_initiator
    self.initiator = current_user
  end

  def set_current_user_on_entry
    entry.set_current_user current_user
  end
end
