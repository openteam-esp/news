class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :title
      t.references :context
      t.timestamps
    end
  end
end
