class CreateContexts < ActiveRecord::Migration
  def up
    create_table :contexts do |t|
      t.string :title
      t.string :ancestry
      t.string :weight
      t.timestamps
    end
    add_index :contexts, :weight
    add_index :contexts, :ancestry
  end

  def down
    drop_table :contexts
  end
end
