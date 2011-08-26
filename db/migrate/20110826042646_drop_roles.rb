class DropRoles < ActiveRecord::Migration
  def self.up
    drop_table :roles
    drop_table :roles_users
    add_column :users, :roles, :text
  end

  def self.down
    create_table :roles do |t|
      t.string :kind
      t.timestamps
    end
    create_table :roles_users do |t|
      t.integer "role_id"
      t.integer "user_id"
    end
    remove_column :users, :roles
  end
end
