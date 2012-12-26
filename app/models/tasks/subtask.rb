# encoding: utf-8
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


class Subtask < Task
  attr_accessible :description, :executor_id

  belongs_to :issue
  belongs_to :entry

  validates_presence_of :executor, :description, :entry
  validate :not_itself_assigned, :on => :create

  before_validation :set_entry, :unless => :entry

  scope :opened, where(:state => [:fresh, :processing])

  state_machine :initial => :fresh do
    before_transition :set_current_user_on_entry
    after_transition :create_event

    state :fresh
    state :processing
    state :completed
    state :refused
    state :canceled

    event :accept do
      transition :fresh => :processing, :unless => :deleted?
    end

    event :complete do
      transition :processing => :completed, :unless => :deleted?
    end

    event :refuse do
      transition [:fresh, :processing] => :refused, :unless => :deleted?
    end

    event :cancel do
      transition [:fresh, :processing] => :canceled, :unless => :deleted?
    end

    event :clear do
      transition [:fresh, :processing] => :canceled, :unless => :deleted?
    end
  end

  def self.human_state_events
    Task.human_state_events + [:cancel]
  end

  def executors_without_initiator
    User.where('id not in (?)', current_user.id)
  end

  def truncated_description
    description.truncate(60, :omission => '…')
  end

  private

    def set_entry
      self.entry = issue.entry
    end

    def not_itself_assigned
      self.errors[:executor_id] = 'Нелья назначить подзадачу себе' if executor == current_user
    end


end
