class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels, :force => true do |t|
      t.datetime    :deleted_at
      t.references  :context
      t.string      :ancestry
      t.string      :title
      t.text        :weight
      t.timestamps
    end
    add_index :channels,  :ancestry
    add_index :channels,  :context_id
    add_index :channels,  :weight
  end
end
