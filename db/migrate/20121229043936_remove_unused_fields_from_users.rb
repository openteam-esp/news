class RemoveUnusedFieldsFromUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :nickname
      t.remove :location
      t.remove :description
      t.remove :image
      t.remove :phone
      t.remove :urls
      t.change :name, :string
      t.change :email, :string
      t.change :first_name, :string
      t.change :last_name, :string
    end
  end

  def down
  end
end
