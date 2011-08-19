class EntriesController < AuthorizedApplicationController

  belongs_to :folder, :finder => :find_by_title, :optional => true

  actions :all, :except => :new

  build_nested_objects_for :all

  load_and_authorize_resource

  has_scope :page, :default => 1

  has_scope :filters, :default => true, :type => :boolean do |controller, scope|
    scope.filter_for(controller.current_user, controller.params[:folder_id])
  end

  def create
    create! { edit_folder_entry_path(@entry.folder, @entry) }
  end

end
