class Manage::News::SubtasksController < Manage::ApplicationController
  layout false

  actions :new, :create

  belongs_to :issue

  def create
    @issue.entry.current_user = current_user
    create! do | success, failure |
      success.html { render :partial => @subtask }
      failure.html { render :new }
    end
  end

end
