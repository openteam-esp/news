class AddSourceTagetToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :source_target, :string
  end
end
