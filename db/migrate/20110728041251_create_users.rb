class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do | t |
      t.text :name
      t.text :roles
      t.database_authenticatable :null => true
      t.recoverable
      t.rememberable
      t.trackable
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
