class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks, :force => true do |t|
      t.datetime :deleted_at
      t.integer  :entry_id
      t.integer  :executor_id
      t.integer  :initiator_id
      t.integer  :issue_id
      t.string   :state
      t.string   :type
      t.text     :comment
      t.text     :description
      t.timestamps
    end

    add_index :tasks, :entry_id
    add_index :tasks, :executor_id
    add_index :tasks, :initiator_id
    add_index :tasks, :issue_id
  end
end
