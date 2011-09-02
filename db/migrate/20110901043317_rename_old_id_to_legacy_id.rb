class RenameOldIdToLegacyId < ActiveRecord::Migration
  def self.up
    rename_column :entries, :old_id, :legacy_id
    add_column :assets, :legacy_id, :integer
    remove_column :entries, :old_channel_id
    remove_column :recipients, :old_id
  end

  def self.down
    rename_column :entries, :legacy_id, :old_id
    remove_column :assets, :legacy_id
    add_column :entries, :old_channel_id, :integer
    add_column :recipients, :old_id, :integer
  end
end
