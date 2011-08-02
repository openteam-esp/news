class RootsController < ApplicationController
  def index
    redirect_to messages_path and return if current_user
    redirect_to channel_published_entries_path(Channel.first) and return
  end
end

