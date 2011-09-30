class Publish < Issue
  state_machine :initial => :pending do

    before_transition :authorize_transition
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
      transition :fresh => :processing
    end
    event :complete do
      transition :processing => :completed
    end
    event :refuse do
      transition :processing => :fresh
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

