class IssuesController < AuthorizedApplicationController
  load_and_authorize_resource

  has_scope :kind, :default => 'fresh_tasks'
end
