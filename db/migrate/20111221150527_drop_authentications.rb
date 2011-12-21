class DropAuthentications < ActiveRecord::Migration
  def up
    drop_table :authentications
  end

  def down
    create_table "authentications", :force => true do |t|
      t.integer "user_id"
      t.string  "provider"
      t.string  "uid"
    end
    add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"
  end
end
