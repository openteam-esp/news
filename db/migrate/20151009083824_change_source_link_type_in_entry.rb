class ChangeSourceLinkTypeInEntry < ActiveRecord::Migration
  def up
    change_column :entries, :source_link, :text
  end
end
