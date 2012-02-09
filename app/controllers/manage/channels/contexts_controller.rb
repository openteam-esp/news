class Manage::Channels::ContextsController < Manage::Channels::ApplicationController
  has_scope :with_manage_permission, :type => :boolean, :default => true do | controller, scope, value |
    scope.with_manager_permissions_for(controller.current_user)
  end
  has_scope :with_channels, :type => :boolean, :default => true
  has_scope :page, :default => 1
end
