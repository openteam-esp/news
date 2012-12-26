class CreateLocks < ActiveRecord::Migration
  def change
    create_table :locks do |t|
      t.references :entry
      t.references :user

      t.timestamps
    end
    add_index :locks, :entry_id, :uniq => true
    add_index :locks, :user_id
  end
end
