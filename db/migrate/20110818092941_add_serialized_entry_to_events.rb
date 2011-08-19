class AddSerializedEntryToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :serialized_entry, :text
    remove_column :entries, :serialized_assets
  end

  def self.down
    remove_column :events, :serialized_entry
    add_column :entries, :serialized_assets, :text
  end
end
