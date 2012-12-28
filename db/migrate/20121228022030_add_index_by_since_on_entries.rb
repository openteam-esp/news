class AddIndexBySinceOnEntries < ActiveRecord::Migration
  def change
    add_index :entries, :since
  end
end
