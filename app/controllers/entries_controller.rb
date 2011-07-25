class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!

  belongs_to :folder, :finder => :find_by_title

  load_and_authorize_resource

  has_scope :filters, :default => true, :type => :boolean do |controller, scope|
    scope.filter_for(controller.current_user, controller.params[:folder_id])
  end
end
