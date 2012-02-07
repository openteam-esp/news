class CreateEntries < ActiveRecord::Migration
  def change
    create_table "entries", :force => true do |t|
      t.datetime "locked_at"
      t.datetime "since"
      t.datetime "until"
      t.integer  "deleted_by_id"
      t.integer  "destroy_entry_job_id"
      t.integer  "initiator_id"
      t.integer  "legacy_id"
      t.integer  "locked_by_id"
      t.string   "author"
      t.string   "slug"
      t.string   "state"
      t.string   "vfs_path"
      t.text     "annotation"
      t.text     "body"
      t.text     "title"
      t.timestamps
    end

    add_index "entries", ["deleted_by_id"], :name => "index_entries_on_deleted_by_id"
    add_index "entries", ["destroy_entry_job_id"], :name => "index_entries_on_destroy_entry_job_id"
    add_index "entries", ["initiator_id"], :name => "index_entries_on_initiator_id"
    add_index "entries", ["legacy_id"], :name => "index_entries_on_legacy_id"
    add_index "entries", ["locked_by_id"], :name => "index_entries_on_locked_by_id"
  end
end
