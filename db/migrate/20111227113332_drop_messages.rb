class DropMessages < ActiveRecord::Migration
  def up
    drop_table :messages
  end

  def down
    create_table "messages", :force => true do |t|
      t.integer  "event_id"
      t.integer  "user_id"
      t.text     "text"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "messages", ["event_id"], :name => "index_messages_on_event_id"
    add_index "messages", ["user_id"], :name => "index_messages_on_user_id"
  end
end
