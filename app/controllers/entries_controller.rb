class EntriesController < InheritedResources::Base
  load_and_authorize_resource

  before_filter :authenticate_user!

  belongs_to :folder, :finder => :find_by_title
end
