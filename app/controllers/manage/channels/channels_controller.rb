class Manage::Channels::ChannelsController < Manage::Channels::ApplicationController

  has_scope :page, :default => 1, :only => :index

  has_scope :with_manage_permission, :type => :boolean, :default => true do | controller, scope, value |
    scope.with_manager_permissions_for(controller.current_user)
  end

  def create
    create! { manage_channels_root_path }
  end

  def destroy
    destroy! { manage_channels_root_path }
  end

  def update
    update! { manage_channels_root_path }
  end
end
