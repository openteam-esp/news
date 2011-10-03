class AddDelayedJobToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :destroy_entry_job_id, :integer
  end

  def self.down
    remove_column :entries, :destroy_entry_job_id
  end
end
