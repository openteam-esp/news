class ChannelsController < ApplicationController
  inherit_resources
  actions :index, :show
  respond_to :json
end
