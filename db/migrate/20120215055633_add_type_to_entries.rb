class AddTypeToEntries < ActiveRecord::Migration
  def up
    add_column :entries, :type, :string
    Entry.update_all :type => 'NewsEntry'
    Entry.reindex
  end

  def down
    remove_column :entries, :type
  end
end
