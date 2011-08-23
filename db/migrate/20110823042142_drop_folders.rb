class DropFolders < ActiveRecord::Migration
  def self.up
    drop_table :folders
    remove_column :entries, :folder_id
  end

  def self.down
    create_table "folders", :force => true do |t|
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_column :entries, :folder_id, :integer
  end
end
