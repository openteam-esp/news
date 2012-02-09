class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings, :force => true do |t|
      t.references  :follower
      t.references  :target
      t.timestamps
    end

    add_index :followings, :follower_id
    add_index :followings, :target_id
  end
end
