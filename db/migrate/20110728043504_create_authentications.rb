class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do | t |
      t.belongs_to  :user
      t.string      :provider
      t.string      :uid
    end
  end

  def self.down
    drop_table :authentications
  end
end
