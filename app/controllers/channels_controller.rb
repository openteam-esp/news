class ChannelsController < ApplicationController
  inherit_resources
  actions :index, :show
  respond_to :json

  def index
    index! do |format|
      format.json { render :json => Channel.arrange_as_array }
    end
  end

  def show
    show! do |format|
      format.html { redirect_to root_url, :status => 301 }
    end
  end
end
