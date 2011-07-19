class RootsController < ApplicationController
  def index
    redirect_to folder_entries_path(:inbox) and return if current_user
    redirect_to channel_published_entries_path(Channel.first) and return
  end
end

