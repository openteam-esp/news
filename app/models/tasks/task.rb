class Task < ActiveRecord::Base
  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'

  validates_presence_of :entry, :initiator

  before_validation :set_initiator

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


  protected

    delegate :current_user, :to => :entry

    def set_initiator
      self.initiator = entry.current_user
    end

    def authorize_transition(transition)
      Ability.new(current_user).authorize!(transition.event, self) if human_state_events.include? transition.event
    end

    def create_event(transition)
      entry.events.create! :entry => entry, :task => self, :event => transition.event.to_s, :user => current_user if self.class.human_state_events.include? transition.event
    end

end

# == Schema Information
#
# Table name: tasks
#
#  comment      :text
#  created_at   :datetime         not null
#  deleted_at   :datetime
#  description  :text
#  entry_id     :integer
#  executor_id  :integer
#  id           :integer          not null, primary key
#  initiator_id :integer
#  issue_id     :integer
#  state        :string(255)
#  type         :string(255)
#  updated_at   :datetime         not null
#

