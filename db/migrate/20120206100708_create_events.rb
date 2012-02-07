class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events, :force => true do |t|
      t.integer  :entry_id
      t.integer  :task_id
      t.integer  :user_id
      t.string   :event
      t.text     :serialized_entry
      t.text     :text
      t.timestamps
    end

    add_index :events, :entry_id
    add_index :events, :task_id
    add_index :events, :user_id
  end
end
