class Manage::RootsController < Manage::ApplicationController
  def index
    redirect_to tasks_path(:fresh) and return if current_user
    redirect_to public_entries_path
  end
end

