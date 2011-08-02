class CreateSubscribes < ActiveRecord::Migration
  def self.up
    create_table :subscribes do |t|
      t.integer :subscriber_id
      t.integer :initiator_id
      t.integer :entry_id
      t.string :kind

      t.timestamps
    end
  end

  def self.down
    drop_table :subscribes
  end
end
