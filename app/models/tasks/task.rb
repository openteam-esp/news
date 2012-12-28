# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
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

  has_many :channels, :through => :entry
  has_many :images, :through => :entry

  before_create :set_initiator

  validates_presence_of :current_user

  scope :ordered, order('id desc')

  scope :not_deleted,   -> { joins(:entry).where(:entries => {:deleted_at => nil}) }
  scope :not_published, -> { joins(:entry).where(:entries => {:state      => Entry.non_published_states}) }

  scope :processing,    -> { where(:state => :processing) }
  scope :useful,        -> { where(:state => Task.useful_states) }

  scope :for_channel, ->(channel) do
    joins(:entry).joins(:channel)
  end

  scope :folder, ->(folder, user) do
    send(folder, user)
      .not_deleted
      .not_published
      .order('tasks.id desc')
  end

  scope :fresh, ->(user) do
    types = ['Subtask']
    types << 'Review' if user.corrector? || user.manager?
    types << 'Publish' if user.publisher? || user.manager?
    where(:type => types)
      .where(:tasks => {:state => :fresh})
      .where(['executor_id IS NULL OR executor_id = ?', user])
      .joins(:channels)
        .where("channels.id IN (#{Channel.subtree_for(user).select(:id).to_sql})")
  end

  scope :processed_by_me, ->(user) do
    processing.where(:executor_id => user)
  end

  scope :initiated_by_me, ->(user) do
    useful.where('tasks.initiator_id' => user)
  end

  delegate :prepare, :review, :publish, :to => :entry
  delegate :fresh?, :to => :next_task, :prefix => true

  def self.all_states
    @all_states ||= Task.descendants.flat_map{|c| c.state_machine(:state).states.map(&:name) }
  end

  def self.useful_states
    @useful_states ||= all_states - [:completed, :pending]
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
