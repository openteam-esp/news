# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110902025359) do

  create_table "assets", :force => true do |t|
    t.string   "type"
    t.integer  "entry_id"
    t.string   "file_name"
    t.string   "file_mime_type"
    t.integer  "file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "file_uid"
    t.integer  "file_width"
    t.integer  "file_height"
    t.integer  "legacy_id"
    t.text     "description"
  end

  create_table "authentications", :force => true do |t|
    t.integer "user_id"
    t.string  "provider"
    t.string  "uid"
  end

  create_table "channels", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "channels_entries", :id => false, :force => true do |t|
    t.integer "channel_id"
    t.integer "entry_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "entries", :force => true do |t|
    t.text     "title"
    t.text     "annotation"
    t.text     "body"
    t.datetime "since"
    t.datetime "until"
    t.string   "state"
    t.string   "author"
    t.integer  "initiator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legacy_id"
  end

  create_table "events", :force => true do |t|
    t.string   "kind"
    t.text     "text"
    t.integer  "entry_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "serialized_entry"
  end

  create_table "messages", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipients", :force => true do |t|
    t.string   "email"
    t.text     "description"
    t.boolean  "active"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscribes", :force => true do |t|
    t.integer  "subscriber_id"
    t.integer  "initiator_id"
    t.integer  "entry_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.text     "name"
    t.string   "email"
    t.string   "encrypted_password",     :limit => 128
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "roles"
  end

end
