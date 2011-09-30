# encoding: utf-8

class Subtask < Task

  belongs_to :issue

  default_value_for :initiator do User.current end

  validates_presence_of :executor, :description, :entry
  validate :not_itself_assigned

  state_machine :initial => :fresh do

    before_transition :authorize_transition
    after_transition :create_event
    after_transition :on => :complete, :do => :after_complete
    after_transition :on => :accept, :do => :after_accept
    after_transition :on => :restore, :do => :after_restore

    state :fresh
    state :processing
    state :completed
    state :canceled

    event :accept do
      transition :fresh => :processing
    end

    event :complete do
      transition :processing => :completed
    end

    event :cancel do
      transition [:fresh, :processing] => :canceled
    end

    event :refuse do
      transition [:fresh, :processing] => :refused
    end
  end

  def self.human_state_events
    Task.human_state_events + [:cancel]
  end

  def executors_without_initiator
    User.where('id not in (?)', initiator_id)
  end

  private
    def not_itself_assigned
      self.errors[:executor_id] = 'Нелья назначить подзадачу себе' if executor_id == initiator_id
    end


end




# == Schema Information
#
# Table name: tasks
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#  issue_id     :integer
#  description  :text
#  deleted_at   :datetime
#

