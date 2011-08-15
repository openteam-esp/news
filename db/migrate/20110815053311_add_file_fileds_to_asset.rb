class AddFileFiledsToAsset < ActiveRecord::Migration
  def self.up
    drop_table :assets
    drop_table :ckeditor_assets
    create_table :assets do | t |
      t.string      :type
      t.belongs_to  :entry
      t.string      :file_file_name
      t.string      :file_content_type
      t.integer     :file_file_size
      t.datetime    :file_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
    create_table :assets do | t |
      t.string    :image_file_name
      t.string    :image_content_type
      t.integer   :image_file_size
      t.datetime  :image_updated_at
      t.string    :attachment_file_name
      t.string    :attachment_content_type
      t.integer   :attachment_file_size
      t.datetime  :attachment_updated_at
      t.timestamps
    end

    create_table "ckeditor_assets", :force => true do |t|
      t.string   "data_file_name",                                 :null => false
      t.string   "data_content_type"
      t.integer  "data_file_size"
      t.integer  "assetable_id"
      t.string   "assetable_type",    :limit => 30
      t.string   "type",              :limit => 25
      t.string   "guid",              :limit => 10
      t.integer  "locale",            :limit => 1,  :default => 0
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "old_id"
    end

    add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "fk_assetable"
    add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_assetable_type"
    add_index "ckeditor_assets", ["user_id"], :name => "fk_user"
  end

end
