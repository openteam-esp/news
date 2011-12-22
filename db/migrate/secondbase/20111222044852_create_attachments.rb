class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table "attachments", :force => true do |t|
      t.string   "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.integer  "file_file_size"
      t.integer  "event_id"
      t.string   "type"
    end
  end

  def self.down
    drop_table :attachments
  end
end
