class AddVfsPathToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :vfs_path, :string
  end
end
