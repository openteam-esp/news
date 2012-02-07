class Manage::TasksController < Manage::ApplicationController
  layout 'manage/list'

  actions :index
  custom_actions :resource => :fire_event
  skip_authorize_resource :only => :index

  has_scope :folder do | controller, scope, value |
    scope.folder(value, controller.current_user)
  end

  has_scope :page, :default => 1, :only => :index

  def fire_event
    fire_event! {
      @task.comment = params[:task][:comment] if params[:task][:comment]
      @task.current_user = current_user
      begin
        @task.fire_events! params[:task][:event].to_sym
      rescue => e
        flash[:alert] = I18n.t('News is not complete')
      end
      redirect_to manage_entry_path(@task.entry) and return
    }
  end

end
