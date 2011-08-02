class AddVersionToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :version_id, :integer
  end

  def self.down
    remove_column :events, :version_id
  end
end
