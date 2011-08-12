class AssetsController < InheritedResources::Base #ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  def create
    if params[:image]
      asset = Asset.create!(:image => params[:file])
      render :text => asset.image.url
    end
    if params[:attachment]
      asset = Asset.create!(:attachment => params[:file])
      render :text => "<a href=#{asset.attachment.url} rel=#{asset.id} class='redactor_file_link'>#{asset.attachment_file_name}</a>"
    end
  end
end
