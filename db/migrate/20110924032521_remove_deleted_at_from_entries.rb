class RemoveDeletedAtFromEntries < ActiveRecord::Migration
  def self.up
    remove_column :entries, :deleted_at
  end

  def self.down
    add_column :entries, :deleted_at, :datetime
  end
end
