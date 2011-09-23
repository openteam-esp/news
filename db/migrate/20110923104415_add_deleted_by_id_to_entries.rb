class AddDeletedByIdToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :deleted_by_id, :integer
  end

  def self.down
    remove_column :entries, :deleted_by_id
  end
end
