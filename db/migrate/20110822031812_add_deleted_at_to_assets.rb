class AddDeletedAtToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :deleted_at, :datetime
    remove_column :entries, :deleted
  end

  def self.down
    remove_column :assets, :deleted_at
    add_column :entries, :deleted, :boolean
  end
end
