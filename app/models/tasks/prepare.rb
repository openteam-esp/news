class Prepare < Task
  state_machine :initial => :processing do
    state :processing
    state :completed

    event :complete do
      transition :processing => :completed
    end

    event :restore do
      transition :completed => :processing
    end
  end

  def next_task
    entry.review
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
#

