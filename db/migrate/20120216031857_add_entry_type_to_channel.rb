class AddEntryTypeToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :entry_type, :string
  end
end
