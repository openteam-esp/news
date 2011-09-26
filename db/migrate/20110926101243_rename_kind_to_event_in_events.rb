class RenameKindToEventInEvents < ActiveRecord::Migration
  def self.up
    rename_column :events, :kind, :event
  end

  def self.down
    rename_column :events, :event, :kind
  end
end
