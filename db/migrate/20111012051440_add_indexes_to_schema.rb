class AddIndexesToSchema < ActiveRecord::Migration
  def self.up
    add_index :assets, :entry_id
    add_index :authentications, :user_id
    add_index :channels_entries, :channel_id
    add_index :channels_entries, :entry_id
    add_index :entries, :initiator_id
    add_index :entries, :locked_by_id
    add_index :entries, :deleted_by_id
    add_index :entries, :destroy_entry_job_id
    add_index :events, :entry_id
    add_index :events, :user_id
    add_index :events, :task_id
    add_index :followings, :follower_id
    add_index :followings, :target_id
    add_index :messages, :event_id
    add_index :messages, :user_id
    add_index :recipients, :channel_id
    add_index :subscribes, :subscriber_id
    add_index :subscribes, :initiator_id
    add_index :subscribes, :entry_id
    add_index :tasks, :entry_id
    add_index :tasks, :initiator_id
    add_index :tasks, :executor_id
    add_index :tasks, :issue_id
  end

  def self.down
    remove_index :tasks, :column => :issue_id
    remove_index :tasks, :column => :executor_id
    remove_index :tasks, :column => :initiator_id
    remove_index :tasks, :column => :entry_id
    remove_index :subscribes, :column => :entry_id
    remove_index :subscribes, :column => :initiator_id
    remove_index :subscribes, :column => :subscriber_id
    remove_index :recipients, :column => :channel_id
    remove_index :messages, :column => :user_id
    remove_index :messages, :column => :event_id
    remove_index :followings, :column => :target_id
    remove_index :followings, :column => :follower_id
    remove_index :events, :column => :task_id
    remove_index :events, :column => :user_id
    remove_index :events, :column => :entry_id
    remove_index :entries, :column => :destroy_entry_job_id
    remove_index :entries, :column => :deleted_by_id
    remove_index :entries, :column => :locked_by_id
    remove_index :entries, :column => :initiator_id
    remove_index :channels_entries, :column => :entry_id
    remove_index :channels_entries, :column => :channel_id
    remove_index :authentications, :column => :user_id
    remove_index :assets, :column => :entry_id
  end
end
