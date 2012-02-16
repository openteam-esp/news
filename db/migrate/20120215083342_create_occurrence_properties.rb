class CreateOccurrenceProperties < ActiveRecord::Migration
  def change
    create_table :occurrence_properties do |t|
      t.datetime :since
      t.datetime :until
      t.references :occurrence
      t.text :location
      t.timestamps
    end
  end
end
