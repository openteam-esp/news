class SubtasksController < AuthorizedApplicationController
  belongs_to :issue
  actions :create

  authorize_resource

  def create
    create! { entry_path(parent.entry) }
  end
end

