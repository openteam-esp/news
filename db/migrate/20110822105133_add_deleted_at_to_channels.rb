class AddDeletedAtToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels, :deleted_at, :datetime
  end

  def self.down
    remove_column :channels, :deleted_at
  end
end
