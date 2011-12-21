# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20111221150527) do

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
  end

  add_index "assets", ["entry_id"], :name => "index_assets_on_entry_id"
  add_index "assets", ["legacy_id"], :name => "index_assets_on_legacy_id"

  create_table "channels", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "slug"
  end

  create_table "channels_entries", :id => false, :force => true do |t|
    t.integer "channel_id"
    t.integer "entry_id"
  end

  add_index "channels_entries", ["channel_id"], :name => "index_channels_entries_on_channel_id"
  add_index "channels_entries", ["entry_id"], :name => "index_channels_entries_on_entry_id"

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
    t.datetime "locked_at"
    t.integer  "locked_by_id"
    t.integer  "deleted_by_id"
    t.integer  "destroy_entry_job_id"
    t.string   "slug"
  end

  add_index "entries", ["deleted_by_id"], :name => "index_entries_on_deleted_by_id"
  add_index "entries", ["destroy_entry_job_id"], :name => "index_entries_on_destroy_entry_job_id"
  add_index "entries", ["initiator_id"], :name => "index_entries_on_initiator_id"
  add_index "entries", ["legacy_id"], :name => "index_entries_on_legacy_id"
  add_index "entries", ["locked_by_id"], :name => "index_entries_on_locked_by_id"

  create_table "events", :force => true do |t|
    t.string   "event"
    t.text     "text"
    t.integer  "entry_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "serialized_entry"
    t.integer  "task_id"
  end

  add_index "events", ["entry_id"], :name => "index_events_on_entry_id"
  add_index "events", ["task_id"], :name => "index_events_on_task_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "followings", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"
  add_index "followings", ["target_id"], :name => "index_followings_on_target_id"

  create_table "messages", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["event_id"], :name => "index_messages_on_event_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "recipients", :force => true do |t|
    t.string   "email"
    t.text     "description"
    t.boolean  "active"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipients", ["channel_id"], :name => "index_recipients_on_channel_id"

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

  create_table "tasks", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "initiator_id"
    t.integer  "executor_id"
    t.string   "state"
    t.string   "type"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "issue_id"
    t.text     "description"
    t.datetime "deleted_at"
  end

  add_index "tasks", ["entry_id"], :name => "index_tasks_on_entry_id"
  add_index "tasks", ["executor_id"], :name => "index_tasks_on_executor_id"
  add_index "tasks", ["initiator_id"], :name => "index_tasks_on_initiator_id"
  add_index "tasks", ["issue_id"], :name => "index_tasks_on_issue_id"

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.text     "name"
    t.text     "email"
    t.text     "nickname"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "location"
    t.text     "description"
    t.text     "image"
    t.text     "phone"
    t.text     "urls"
    t.text     "raw_info"
    t.text     "roles"
    t.integer  "sign_in_count",      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["uid"], :name => "index_users_on_uid"

end
