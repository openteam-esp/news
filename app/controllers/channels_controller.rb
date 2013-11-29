class ChannelsController < ApplicationController
  inherit_resources
  actions :index, :show
  respond_to :json

  def show
    show! do |format|
      format.html { redirect_to root_url, :status => 301 }
    end
  end
end
