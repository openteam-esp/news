class SubtasksController < AuthorizedApplicationController
  layout false

  actions :new, :create

  belongs_to :issue

  def create
    create! do | success, failure |
      success.html { render :partial => @subtask }
      failure.html { render :new }
    end
  end

end
