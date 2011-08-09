class AddOldIdToTables < ActiveRecord::Migration
  def self.up
    add_column :entries, :old_id, :integer
    add_column :ckeditor_assets, :old_id, :integer
    add_column :recipients, :old_id, :integer
  end

  def self.down
    remove_column :recipients, :old_id
    remove_column :ckeditor_assets, :old_id
    remove_column :entries, :old_id
  end
end
