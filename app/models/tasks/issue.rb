class Issue < Task

  has_many :subtasks, :before_add => :set_entry

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
      next_task.try :clear!
    end

    def after_accept
    end

    def after_restore
      entry.down!
      next_task.try :suspend!
    end

    def after_refuse
      cancel_subtasks
    end

    def change_executor
      update_attributes!({:executor => current_user}, :without_protection => true)
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

