class CreateFollowings < ActiveRecord::Migration
  def change
    create_table "followings", :force => true do |t|
      t.integer  "follower_id"
      t.integer  "target_id"
      t.timestamps
    end

    add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"
    add_index "followings", ["target_id"], :name => "index_followings_on_target_id"
  end
end
