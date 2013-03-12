class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.text :url
      t.text :description
      t.references :entry

      t.timestamps
    end

    add_index :images, :entry_id

    Entry.all.select(&:image_url?).each do |entry|
      entry.images.create!(:url => entry.image_url, :description => entry.image_description)
    end

    remove_column :entries, :image_url
    remove_column :entries, :image_description
  end

  def down
    add_column :entries, :image_url, :string
    add_column :entries, :image_description, :string
    drop_table :images
  end
end
