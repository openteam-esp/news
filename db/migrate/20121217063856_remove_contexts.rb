class Context < ActiveRecord::Base
  esp_auth_context :subcontext => 'Channel'

  has_many :channels

  scope :with_manager_permissions_for, ->(user) {
    context_ids = user.permissions.for_role(:manager).for_context_type('Context').pluck('distinct context_id')
    where(:id => Context.where(:id => context_ids).flat_map(&:subtree_ids))
  }

  scope :with_channels, joins(:channels).uniq

  def polymorphic_context_value
    "#{self.class.name.underscore}_#{self.id}"
  end
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

  def down
  end
end
