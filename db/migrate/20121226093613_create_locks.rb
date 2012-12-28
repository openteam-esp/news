class CreateLocks < ActiveRecord::Migration
  def up
    create_table :locks do |t|
      t.references :entry
      t.references :user

      t.timestamps
    end
    add_index :locks, :entry_id, :uniq => true
    add_index :locks, :user_id
    require 'timecop'
    Entry.where('locked_by_id IS NOT NULL').each do |entry|
      Timecop.freeze(entry.attributes['locked_at']) do
        entry.current_user = User.find(entry.attributes['locked_by_id'])
        entry.lock
      end
    end
    remove_column :entries, :locked_by_id
    remove_column :entries, :locked_at
  end
end
