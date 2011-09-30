class TasksController < AuthorizedApplicationController
  actions :index
  custom_actions :resource => :fire_event

  layout 'system/list'
  has_scope :kind
  has_scope :page, :default => 1, :only => :index

  def fire_event
    fire_event! {
      @task.comment = params[:task][:comment] if params[:task][:comment]
      begin
        @task.fire_events! params[:task][:event].to_sym
      rescue => e
        flash[:alert] = I18n.t('News is not complete')
      end
      redirect_to entry_path(@task.entry) and return
    }
  end

end
