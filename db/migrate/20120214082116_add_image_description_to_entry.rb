class AddImageDescriptionToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :image_description, :string
  end
end
