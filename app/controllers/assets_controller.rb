class AssetsController < AuthorizedApplicationController
  belongs_to :entry

  load_and_authorize_resource

  actions :create, :destroy, :show

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

  def show
    show! do
      redirect_to @asset.file.url
      #send_file @asset.file.path, :type => @asset.file.mime_type
      return
    end
  end
end

