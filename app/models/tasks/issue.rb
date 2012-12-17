class Issue < Task

  has_many :subtasks, :before_add => :set_entry

  def next_task
  end

  def description
    self.class.model_name.human
  end

  delegate :opened, :to => :subtasks, :prefix => true

  protected
    def set_entry(subtask)
      subtask.entry = entry
    end

    def cancel_subtasks
      subtasks_opened.each do |subtask|
        subtask.clear!
      end
    end

    def after_complete
      cancel_subtasks
      entry.up!
      if next_task
        next_task.entry.current_user = current_user
        next_task.clear!
      end
    end

    def after_accept
      update_attributes! :executor => current_user
    end

    def after_restore
      update_attributes! :executor => current_user
      entry.down!
      if next_task
        next_task.entry.current_user = current_user
        next_task.suspend!
      end
    end

    def after_refuse
      cancel_subtasks
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

