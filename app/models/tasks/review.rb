class Review < Issue
  state_machine :initial => :pending do
    before_transition :set_current_user_on_entry
    after_transition :create_event
    after_transition :on => :accept, :do => :change_executor
    after_transition :on => :complete, :do => [:change_executor, :after_complete]
    after_transition :on => :restore, :do => :after_restore
    after_transition :on => :refuse, :do => :after_refuse

    state :pending
    state :fresh
    state :processing
    state :completed

    event :clear do
      transition :pending => :fresh
    end
    event :accept do
      transition :fresh => :processing, :unless => :deleted?
    end
    event :complete do
      transition :processing => :completed, :unless => :deleted?
    end
    event :refuse do
      transition :processing => :fresh, :unless => :deleted?
    end
    event :suspend do
      transition :fresh => :pending
    end
    event :restore do
      transition :completed => :processing, :if => :next_task_fresh?, :unless => :deleted?
    end
  end

  def next_task
    entry.publish
  end
end

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

