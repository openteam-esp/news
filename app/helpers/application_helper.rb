# encoding: utf-8

module ApplicationHelper
  def resized_image_tag(image)
    width = 100
    if image.file_width > width
      ratio = width / image.file_width.to_f
      height = (image.file_height * ratio).to_i
    else
      width = image.file_width
      height = image.file_height
    end
    image_tag image_path(image, width, height, image.file_name), :alt => "", :size => "#{width}x#{height}"
  end
end

