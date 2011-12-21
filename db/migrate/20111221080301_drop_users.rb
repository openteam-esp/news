class DropUsers < ActiveRecord::Migration
  def up
    drop_table :users
  end

  def down
    create_table "users", :force => true do |t|
      t.text     "name"
      t.string   "email"
      t.string   "encrypted_password",     :limit => 128
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                         :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "roles"
    end
  end
end
