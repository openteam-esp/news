class AddSerializedAssetsToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :serialized_assets, :text
  end

  def self.down
    remove_column :entries, :serialized_assets
  end
end
