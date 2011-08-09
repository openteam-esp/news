class AddOldChannelIdToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :old_channel_id, :integer
  end

  def self.down
    remove_column :entries, :old_channel_id
  end
end
