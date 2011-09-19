class Issue < Task

  has_many :subtasks

  state_machine :initial => :pending do

    before_transition :on => [:accept, :comlpete, :restore] do | task, transition |
      Ability.new.authorize!(transition.event, task)
    end

    state :pending
    state :fresh
    state :processing
    state :completed

    after_transition :on => :accept do | task, transition |
      task.update_attributes! :executor => User.current
    end

    after_transition :on => :complete do |task, transition|
      task.entry.up!
      task.next_task.try :clear!
    end

    after_transition :on => :restore do |task, transition|
      task.entry.down!
      task.next_task.try :suspend!
    end

    event :clear do
      transition :pending => :fresh
    end
    event :accept do
      transition :fresh => :processing
    end
    event :complete do
      transition :processing => :completed
    end
    event :cancel do
      transition :processing => :fresh
    end
    event :suspend do
      transition :fresh => :pending
    end
    event :restore do
      transition :completed => :processing
    end
  end

  def next_task
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
#

