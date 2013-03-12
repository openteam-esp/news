class Context < ActiveRecord::Base
  has_ancestry

  has_many :channels
end

class Channel < ActiveRecord::Base
  belongs_to :context
  has_ancestry
end

class RemoveContexts < ActiveRecord::Migration
  def up
    Permission.where(context_type: 'Context').all.each do |permission|
      if (channels = permission.context.channels.roots).any? || permission.role == 'manager'
        permission.update_attributes(context: channels.first)
        if channels.many?
          (channels - [channels.first]).each do |channel|
            permission.user.permissions.create(context: channel, role: permission.role)
          end
        end
      else
        permission.destroy
      end
    end

    remove_column :channels, :context_id

    drop_table :contexts

    Permission.for_role(:manager).each do |permission|
      Permission.for_context(permission.context).where(:user_id => permission.user).for_role([:initiator, :corrector, :publisher]).destroy_all
    end

    Permission.where(:user_id => User.find_by_uid('1')).where(:context_type => 'Channel').destroy_all
    Permission.where(:user_id => User.find_by_uid('1')).for_context(nil).update_all(:role => :administrator)
  end
end
