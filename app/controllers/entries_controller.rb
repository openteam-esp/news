class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!

  belongs_to :folder, :finder => :find_by_title

  def to_trash
    entry = @folder.entries.find(params[:id])
    entry.update_attribute(:deleted, true) and redirect_to folder_entries_path(:folder => 'trash')
  end
end
