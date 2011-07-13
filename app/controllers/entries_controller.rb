class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!

  belongs_to :folder

  def to_trash
    entry = Entry.find(params[:id])
    entry.update_attribute(:deleted, true) and redirect_to entries_path(:folder => 'trash')
  end
end
