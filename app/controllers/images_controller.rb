class ImagesController < AssetsController

  actions :show

  def show
    show! do
      redirect_to @image.file.thumb(params[:size]).url
      return
    end
  end
end
