class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.belongs_to :entry
      t.belongs_to :initiator
      t.belongs_to :executor
      t.string :state
      t.string :type
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
