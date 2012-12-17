class RenameContextOnPermissions < ActiveRecord::Migration
  def up
    rename_column :permissions, :context_id, :channel_id
    remove_column :permissions, :context_type
  end

  def down
    add_column :permissions, :context_type, :string
    rename_column :permissions, :channel_id, :context_id
  end
end
