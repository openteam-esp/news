class RecreateEvent < ActiveRecord::Migration
  def self.up
    drop_table :events
    create_table "events", :force => true do |t|
      t.string   "kind"
      t.text     "text"
      t.integer  "entry_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "serialized_entry"
    end
  end

  def self.down
    up
  end
end
