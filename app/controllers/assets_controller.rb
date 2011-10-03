class AssetsController < AuthorizedApplicationController
  belongs_to :entry

  layout 'system/ckeditor', :only => :index

  actions :create, :destroy, :index

  has_scope :type, :only => :index

  def create
    create! do |success, failure|
      success.html do
        @assets = params[:type].blank? ? @entry.reload.assets : @entry.reload.assets.type(params[:type].capitalize)
        render :partial => "assets"
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        @assets = @entry.assets
        render :partial => "assets"
      end
    end
  end

end

