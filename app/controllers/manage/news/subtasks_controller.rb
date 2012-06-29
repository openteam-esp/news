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

  private

    alias_method :old_build_resource, :build_resource

    def build_resource
      resource = old_build_resource
      resource.initiator = current_user
      resource
    end
end
