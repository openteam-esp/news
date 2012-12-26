class RenameEventEntryIdToEntryIdInEventEntryProperties < ActiveRecord::Migration
  def change
    rename_column :event_entry_properties, :event_entry_id, :entry_id
  end
end
