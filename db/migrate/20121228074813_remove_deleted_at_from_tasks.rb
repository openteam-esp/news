class RemoveDeletedAtFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :deleted_at
  end

  def down
    add_column :tasks, :deleted_at, :datetime
  end
end
