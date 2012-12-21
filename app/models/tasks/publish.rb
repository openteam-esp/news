class Publish < Issue
  state_machine :initial => :pending do
    after_transition :create_event
    after_transition :on => :complete, :do => :after_complete
    after_transition :on => :accept, :do => :after_accept
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
      transition :completed => :processing
    end
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

