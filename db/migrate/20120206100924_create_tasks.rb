class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks, :force => true do |t|
      t.datetime    :deleted_at
      t.references  :entry
      t.references  :executor
      t.references  :initiator
      t.references  :issue
      t.string      :state
      t.string      :type
      t.text        :comment
      t.text        :description
      t.timestamps
    end

    add_index :tasks, :entry_id
    add_index :tasks, :executor_id
    add_index :tasks, :initiator_id
    add_index :tasks, :issue_id
  end
end
