class CreateChannelsEntries < ActiveRecord::Migration
  def change
    create_table "channels_entries", :id => false, :force => true do |t|
      t.integer "channel_id"
      t.integer "entry_id"
    end

    add_index "channels_entries", ["channel_id"], :name => "index_channels_entries_on_channel_id"
    add_index "channels_entries", ["entry_id"], :name => "index_channels_entries_on_entry_id"
  end
end
