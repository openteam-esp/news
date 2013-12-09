class Manage::ChannelsController < ApplicationController
  layout 'manage/channels'

  sso_load_and_authorize_resource

  has_scope :page, :default => 1, :only => :index
  has_scope :per, :default => 1000, :only => :index
  has_scope :permitted_channels, :default => true, :type => :boolean do | controller, scope, value |
    scope.subtree_for(controller.current_user)
  end

  actions :new, :create, :edit, :update, :index, :destroy
end
