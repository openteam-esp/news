class CreateChannelsEntries < ActiveRecord::Migration
  def change
    create_table :channels_entries, :id => false, :force => true do |t|
      t.references :channel
      t.references :entry
    end

    add_index :channels_entries, :channel_id
    add_index :channels_entries, :entry_id
  end
end
