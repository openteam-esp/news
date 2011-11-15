class AddSlugToChannel < ActiveRecord::Migration
  def self.up
    add_column :channels, :slug, :string
  end

  def self.down
    remove_column :channels, :slug
  end
end
