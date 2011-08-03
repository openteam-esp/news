class VersionsController < ApplicationController
  def show
    @folder = Folder.find_by_title(params[:folder_id])
    @event = Event.find(params[:event_id])
    @version = Version.find(params[:id])
    @entry = @version.reify
  end
end
