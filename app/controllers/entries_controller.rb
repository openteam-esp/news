class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!

  belongs_to :folder, :finder => :find_by_title

  load_and_authorize_resource
end
