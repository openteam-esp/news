class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients, :force => true do |t|
      t.boolean     :active
      t.references  :channel
      t.string      :email
      t.text        :description
      t.timestamps
    end

    add_index :recipients, :channel_id
  end
end
