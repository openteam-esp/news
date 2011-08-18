class MessagesController < AuthorizedApplicationController

  load_and_authorize_resource

  actions :index, :destroy, :update

  has_scope :page, :default => 1

  has_scope :filters, :default => true, :type => :boolean do |controller, scope|
    scope.filter_for(controller.current_user)
  end
end
