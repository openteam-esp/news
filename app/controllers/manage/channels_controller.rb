class Manage::ChannelsController < ApplicationController
  layout 'manage/channels'

  sso_load_and_authorize_resource

  has_scope :page, :default => 1, :only => :index

  actions :new, :create, :edit, :update, :index
end
