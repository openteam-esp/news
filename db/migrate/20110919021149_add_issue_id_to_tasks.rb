class AddIssueIdToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :issue_id, :integer
  end

  def self.down
    remove_column :tasks, :issue
  end
end
