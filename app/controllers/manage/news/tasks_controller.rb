class Manage::News::TasksController < Manage::ApplicationController
  layout 'manage/news/list'

  actions :index

  skip_load_resource
  skip_authorize_resource

  has_scope :folder do |controller, scope, value|
    scope.folder(value, controller.current_user)
  end

  has_scope :page, :default => 1, :only => :index

  expose(:task)

  def update
    authorize! :update, task
    begin
      task.current_user = current_user
      task.save!
    rescue StateMachine::InvalidTransition => e
      flash[:alert] = "#{e.object.class.model_name.human}: #{e.object.errors.to_a.join('; ')}"
    end
    redirect_to manage_news_entry_path(task.entry)
  end
end
