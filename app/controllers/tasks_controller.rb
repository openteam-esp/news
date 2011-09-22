class TasksController < AuthorizedApplicationController
  layout 'list'

  authorize_resource

  has_scope :kind

  def fire_event
    @task.comment = params[:task][:comment] if params[:task][:comment]
    @task.fire_events! params[:task][:event].to_sym
    redirect_to entry_path(@task.entry)
  end
end
