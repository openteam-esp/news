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

class Prepare < Issue
  before_create :set_executor

  state_machine :initial => :processing do
    before_transition :set_current_user_on_entry
    after_transition :create_event
    after_transition :on => :complete, :do => :after_complete
    after_transition :on => :restore, :do => [:change_executor, :after_restore]

    state :processing
    state :completed

    event :complete do
      transition :processing => :completed
    end

    event :restore do
      transition :completed => :processing, :if => :next_task_fresh?
    end
  end

  def next_task
    entry.review
  end

  private

  def set_executor
    self.executor = current_user
  end
end
