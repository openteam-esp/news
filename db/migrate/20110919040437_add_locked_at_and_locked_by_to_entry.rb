class AddLockedAtAndLockedByToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :locked_at, :datetime
    add_column :entries, :locked_by_id, :integer
  end

  def self.down
    remove_column :entries, :locked_by_id
    remove_column :entries, :locked_at
  end
end
