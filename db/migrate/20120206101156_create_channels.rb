class CreateChannels < ActiveRecord::Migration
  def change
    create_table "channels", :force => true do |t|
      t.datetime "deleted_at"
      t.string   "slug"
      t.string   "title"
      t.timestamps
    end
  end
end
