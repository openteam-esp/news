class EntriesController < AuthorizedApplicationController
  actions :index, :show, :create, :edit

  has_scope :state
  has_scope :page, :default => 1

  has_searcher

  load_and_authorize_resource

  def create
    create! { edit_entry_path(@entry) }
  end

  def update
    update! do |success, failure|
      success.html {
        if request.xhr?
          @entry.reload
          @entry.assets.build
          render :edit, :layout => false and return
        end
        redirect_to smart_resource_url
      }
    end
  end
end

