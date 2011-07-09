class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!
  has_scope :folder, :default => 'inbox', :only => :index

  def index
    @entries = apply_scopes(Entry)
  end
end
