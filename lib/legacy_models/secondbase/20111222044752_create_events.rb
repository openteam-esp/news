class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table "events", :force => true do |t|
      t.text     "title"
      t.text     "annotation"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status"
      t.integer  "target_id"
      t.datetime "date_time"
      t.datetime "end_date_time"
    end
  end

  def self.down
    drop_table :events
  end

end
