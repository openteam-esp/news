class CreateEventEntryProperties < ActiveRecord::Migration
  def change
    create_table :event_entry_properties do |t|
      t.datetime :since
      t.datetime :until
      t.references :event_entry
      t.text :location
      t.timestamps
    end
  end
end
