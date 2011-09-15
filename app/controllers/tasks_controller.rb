class TasksController < AuthorizedApplicationController
  layout 'list'
  load_and_authorize_resource

  has_scope :kind
end
