class AddDescriptionToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :description, :text

  end
end
