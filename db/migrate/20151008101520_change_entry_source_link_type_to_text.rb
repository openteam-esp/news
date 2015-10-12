class ChangeEntrySourceLinkTypeToText < ActiveRecord::Migration
  def change
    change_column :entries, :source, :text
  end
end
