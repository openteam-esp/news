class AddTitlePathToChannels < ActiveRecord::Migration
  def up
    add_column :channels, :title_path, :text
    Channel.all.map{|c| c.send :set_title_path; c.save :validate => false}
  end

  def down
    remove_column :channels, :title_path
  end
end
