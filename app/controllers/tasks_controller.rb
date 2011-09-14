class TasksController < AuthorizedApplicationController
  load_and_authorize_resource

  has_scope :kind
end
