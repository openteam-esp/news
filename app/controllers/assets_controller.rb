class AssetsController < AuthorizedApplicationController
  belongs_to :entry

  load_and_authorize_resource

  layout 'ckeditor', :only => :index

  actions :create, :destroy, :index

  def create
    create! do |success, failure|
      success.html do
        render :partial => "assets"
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        render :partial => "assets"
      end
    end
  end

end

