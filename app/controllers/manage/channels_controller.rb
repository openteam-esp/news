class Manage::ChannelsController < ApplicationController
  layout 'manage/channels'

  sso_load_and_authorize_resource

  has_scope :page, :default => 1, :only => :index

  def create
    create! { manage_channels_path }
  end

  def destroy
    destroy! { manage_channels_path }
  end

  def update
    update! { manage_channels_path }
  end
end
