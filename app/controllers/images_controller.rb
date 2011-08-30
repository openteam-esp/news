class ImagesController < AssetsController

  actions :show

  def show
    show! do
      width = [params[:width].to_i, @image.file_width].min
      height = [params[:height].to_i, @image.file_height].min
      redirect_to @image.file.thumb("#{width}x#{height}").url
      return
    end
  end
end
