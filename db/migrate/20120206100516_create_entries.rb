class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries, :force => true do |t|
      t.datetime    :delete_at
      t.datetime    :locked_at
      t.datetime    :since
      t.references  :deleted_by
      t.references  :initiator
      t.references  :legacy
      t.references  :locked_by
      t.string      :author
      t.string      :slug
      t.string      :state
      t.string      :vfs_path
      t.text        :annotation
      t.text        :body
      t.text        :title
      t.timestamps
    end

    add_index :entries, :delete_at
    add_index :entries, :deleted_by_id
    add_index :entries, :initiator_id
    add_index :entries, :legacy_id
    add_index :entries, :locked_by_id
  end
end
