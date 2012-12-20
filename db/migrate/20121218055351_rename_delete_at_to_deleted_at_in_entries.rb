class RenameDeleteAtToDeletedAtInEntries < ActiveRecord::Migration
  def up
    rename_column :entries, :delete_at, :deleted_at
    Entry.deleted.each do |entry|
      entry.update_column :deleted_at, entry.deleted_at - 1.month
    end
  end
end
