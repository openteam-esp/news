class AssetsController < AuthorizedApplicationController
  belongs_to :entry

  layout 'system/ckeditor', :only => :index

  actions :create, :destroy, :index

  has_scope :type, :only => :index

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

