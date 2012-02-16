class AddEntryTypeToChannel < ActiveRecord::Migration
  def up
    add_column :channels, :entry_type, :string
    Channel.all.each do | channel |
      channel.update_attribute :entry_type, 'EntryNews' if channel.children.empty?
    end
  end

  def down
    remove_column :channels, :entry_type
  end
end
