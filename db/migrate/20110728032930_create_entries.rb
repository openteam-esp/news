class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do | t |
      t.text        :title
      t.text        :annotation
      t.text        :body
      t.datetime    :since
      t.datetime    :until
      t.string      :state
      t.boolean     :deleted
      t.string      :author
      t.belongs_to  :initiator
      t.belongs_to  :folder
      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
