class DropSubscribes < ActiveRecord::Migration
  def up
    drop_table :subscribes
  end

  def down
    create_table "subscribes", :force => true do |t|
      t.integer  "subscriber_id"
      t.integer  "initiator_id"
      t.integer  "entry_id"
      t.string   "kind"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "subscribes", ["entry_id"], :name => "index_subscribes_on_entry_id"
    add_index "subscribes", ["initiator_id"], :name => "index_subscribes_on_initiator_id"
    add_index "subscribes", ["subscriber_id"], :name => "index_subscribes_on_subscriber_id"
  end
end
