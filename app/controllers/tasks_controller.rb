class TasksController < AuthorizedApplicationController
  layout 'list'

  actions :index

  custom_actions :resource => :fire_event

  authorize_resource

  has_scope :kind

  def fire_event
    fire_event! {
      @task.comment = params[:task][:comment] if params[:task][:comment]
      @task.fire_events! params[:task][:event].to_sym
      redirect_to entry_path(@task.entry) and return
    }
  end
end
