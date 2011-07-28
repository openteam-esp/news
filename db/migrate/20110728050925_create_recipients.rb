class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :recipients do | t |
      t.string :email
      t.text :description
      t.boolean :active
      t.belongs_to :channel
      t.timestamps
    end
  end

  def self.down
    drop_table :recipients
  end
end
