class AddTitlePathToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :title_path, :text
  end
end
