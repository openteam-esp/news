class RenameIssuesToTasks < ActiveRecord::Migration
  def self.up
    rename_table :issues, :tasks
  end

  def self.down
    rename_table :tasks, :issues
  end
end
