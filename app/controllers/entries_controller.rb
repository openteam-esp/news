class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!
  has_scope :folder, :default => 'inbox', :only => :index

  def index
    @entries = apply_scopes(Entry)
  end

  def to_trash
    entry = Entry.find(params[:id])
    entry.update_attribute(:deleted, true) and redirect_to entries_path(:folder => 'trash')
  end
end
