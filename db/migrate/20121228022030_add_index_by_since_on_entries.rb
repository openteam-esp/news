class AddIndexBySinceOnEntries < ActiveRecord::Migration
  def change
    add_index :entries, :since
    add_index :entries, :state
    add_index :tasks, :state
  end
end
