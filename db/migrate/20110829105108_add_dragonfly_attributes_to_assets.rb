class AddDragonflyAttributesToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :file_uid, :string
    add_column :assets, :file_width, :integer
    add_column :assets, :file_height, :integer
    rename_column :assets, :file_file_size, :file_size
    rename_column :assets, :file_file_name, :file_name
    rename_column :assets, :file_content_type, :file_mime_type
  end

  def self.down
    remove_column :assets, :file_height
    remove_column :assets, :file_width
    remove_column :assets, :file_uid
    rename_column :assets, :file_size, :file_file_size
    rename_column :assets, :file_name, :file_file_name
    rename_column :assets, :file_mime_type, :file_content_type
  end
end
