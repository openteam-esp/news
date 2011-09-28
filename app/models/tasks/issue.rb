class Issue < Task

  has_many :subtasks, :before_add => :set_entry

  def next_task
  end

  protected
    def set_entry(subtask)
      subtask.entry = entry
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

