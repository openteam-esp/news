class AddIndexesToEntry < ActiveRecord::Migration
  def self.up
    add_index :entries, :legacy_id
    add_index :assets, :legacy_id
  end

  def self.down
    remove_index :assets, :column => :legacy_id
    remove_index :entries, :column => :legacy_id
  end
end
