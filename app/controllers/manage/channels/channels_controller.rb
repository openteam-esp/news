class Manage::Channels::ChannelsController < Manage::Channels::ApplicationController
  actions :new, :create, :destroy
  has_scope :page, :default => 1, :only => :index

  def create
    create! {manage_channels_root_path}
  end

  def destroy
    destroy! {manage_channels_root_path}
  end
end
