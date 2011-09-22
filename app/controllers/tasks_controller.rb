class TasksController < AuthorizedApplicationController
  layout 'list'

  actions :index, :create

  optional_belongs_to :task

  custom_actions :resource => :fire_event


  has_scope :kind

  def fire_event
    fire_event! {
      @task.comment = params[:task][:comment] if params[:task][:comment]
      @task.fire_events! params[:task][:event].to_sym
      redirect_to entry_path(@task.entry) and return
    }
  end

  def create
    create! { entry_path(parent.entry) }
  end

  private

    def build_resource
      get_resource_ivar || set_resource_ivar(Issue.find(params[:task_id]).subtasks.build(params[:subtask]))
    end
end
