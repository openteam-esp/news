class Subtask < Task

  belongs_to :issue

  default_value_for :initiator do User.current end

  state_machine :initial => :fresh do
    state :fresh
    state :processing
    state :completed
    state :rejected

    event :accept do
      transition :fresh => :processing
    end

    event :complete do
      transition :processing => :completed
    end

    event :reject do
      transition [:fresh, :processing] => :rejected
    end

    event :refuse do
      transition [:fresh, :processing] => :refused
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
#
