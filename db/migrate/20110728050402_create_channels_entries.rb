class CreateChannelsEntries < ActiveRecord::Migration
  def self.up
    create_table :channels_entries, :id => false do | t |
      t.references :channel, :entry
    end
  end

  def self.down
    drop_table :channels_entries
  end
end
