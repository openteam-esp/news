class AssetsController < AuthorizedApplicationController
  belongs_to :entry

  layout :resolve_layout, :only => :index

  actions :create, :destroy, :index

  has_scope :type, :only => :index

  def index
    index! do
      render :partial => "assets" and return if request.xhr?
    end
  end

  def create
    create! do |success, failure|
      success.html do
        if params[:type].eql?("assets") || params[:type].blank?
          @assets = @entry.reload.assets
        else
          @assets = @entry.reload.assets.type(params[:type].capitalize)
        end
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

  protected

    def resolve_layout
      return request.xhr? ? false : 'system/ckeditor'
    end

end

