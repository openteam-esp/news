class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels, :force => true do |t|
      t.datetime    :deleted_at
      t.integer     :ancestry_depth
      t.references  :context
      t.string      :ancestry
      t.string      :title
      t.timestamps
    end
  end
end
