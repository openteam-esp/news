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

ActiveRecord::Schema.define(:version => 20120214023137) do

  create_table "channels", :force => true do |t|
    t.datetime "deleted_at"
    t.integer  "context_id"
    t.string   "ancestry"
    t.string   "title"
    t.text     "weight"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "channels", ["ancestry"], :name => "index_channels_on_ancestry"
  add_index "channels", ["context_id"], :name => "index_channels_on_context_id"
  add_index "channels", ["weight"], :name => "index_channels_on_weight"

  create_table "channels_entries", :id => false, :force => true do |t|
    t.integer "channel_id"
    t.integer "entry_id"
  end

  add_index "channels_entries", ["channel_id"], :name => "index_channels_entries_on_channel_id"
  add_index "channels_entries", ["entry_id"], :name => "index_channels_entries_on_entry_id"

  create_table "contexts", :force => true do |t|
    t.string   "title"
    t.string   "ancestry"
    t.string   "weight"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "contexts", ["ancestry"], :name => "index_contexts_on_ancestry"
  add_index "contexts", ["weight"], :name => "index_contexts_on_weight"

  create_table "entries", :force => true do |t|
    t.datetime "delete_at"
    t.datetime "locked_at"
    t.datetime "since"
    t.integer  "deleted_by_id"
    t.integer  "initiator_id"
    t.integer  "legacy_id"
    t.integer  "locked_by_id"
    t.string   "author"
    t.string   "slug"
    t.string   "state"
    t.string   "vfs_path"
    t.string   "image_url"
    t.text     "annotation"
    t.text     "body"
    t.text     "title"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "source"
    t.string   "source_link"
  end

  add_index "entries", ["delete_at"], :name => "index_entries_on_delete_at"
  add_index "entries", ["deleted_by_id"], :name => "index_entries_on_deleted_by_id"
  add_index "entries", ["initiator_id"], :name => "index_entries_on_initiator_id"
  add_index "entries", ["legacy_id"], :name => "index_entries_on_legacy_id"
  add_index "entries", ["locked_by_id"], :name => "index_entries_on_locked_by_id"

  create_table "events", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "task_id"
    t.integer  "user_id"
    t.string   "event"
    t.text     "serialized_entry"
    t.text     "text"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "events", ["entry_id"], :name => "index_events_on_entry_id"
  add_index "events", ["task_id"], :name => "index_events_on_task_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "followings", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "target_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"
  add_index "followings", ["target_id"], :name => "index_followings_on_target_id"

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "role"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "permissions", ["user_id", "role", "context_id", "context_type"], :name => "by_user_and_role_and_context"

  create_table "recipients", :force => true do |t|
    t.boolean  "active"
    t.integer  "channel_id"
    t.string   "email"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "recipients", ["channel_id"], :name => "index_recipients_on_channel_id"

  create_table "tasks", :force => true do |t|
    t.datetime "deleted_at"
    t.integer  "entry_id"
    t.integer  "executor_id"
    t.integer  "initiator_id"
    t.integer  "issue_id"
    t.string   "state"
    t.string   "type"
    t.text     "comment"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
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
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "users", ["uid"], :name => "index_users_on_uid"

end
