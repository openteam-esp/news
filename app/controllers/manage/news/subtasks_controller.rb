class Manage::News::SubtasksController < Manage::ApplicationController
  layout false

  actions :new, :create

  belongs_to :issue

  def create
    create! do | success, failure |
      success.html { render :partial => @subtask }
      failure.html { render :new }
    end
  end

  protected
    # TODO remove it
    def evaluate_parent(parent_symbol, parent_config, chain = nil) #:nodoc:
      Task.where(:type => %w[Prepare Review Publish]).find(params[:issue_id])
    end


end
