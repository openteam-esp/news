class RenameDeleteAtToDeletedAtInEntries < ActiveRecord::Migration
  def up
    rename_column :entries, :delete_at, :deleted_at
    Entry.deleted.each do |entry|
      print "#{entry.deleted_at} => "
      entry.update_column :deleted_at, entry.deleted_at - 1.month
      puts entry.deleted_at
    end
  end
end
