Legacy::Entry.connection.create_table "events", :force => true do |t|
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

Legacy::Asset.connection.create_table "attachments", :force => true do |t|
  t.string   "description"
  t.datetime "created_at"
  t.datetime "updated_at"
  t.string   "file_file_name"
  t.string   "file_content_type"
  t.integer  "file_file_size"
  t.integer  "event_id"
  t.string   "type"
end

