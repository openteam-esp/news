class Context < ActiveRecord::Base
  has_ancestry

  has_many :channels
end

class RemoveContexts < ActiveRecord::Migration
  def up
    root_channels = Channel.all.select { |c| c.parent != nil }
    root_channels.each do |c| c.context = nil; c.save! end

    Permission.where(context_type: 'Context').each do |permission|
      Channel.where(context_id: permission.context.subtree_ids).each do |channel|
        permission.user.permissions.create(context: channel, role: permission.role)
      end
      permission.destroy
    end

    remove_column :channels, :context_id
    Channel.update_all(updated_at: Time.now)

    drop_table :contexts
  end
end
