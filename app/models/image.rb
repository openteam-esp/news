class Image < ActiveRecord::Base
  belongs_to :entry

  default_scope order(:id)

  delegate :create_thumbnail, :thumbnail, :width, :height, :to => :esp_commons_image, :allow_nil => true

  def esp_commons_image
    @image ||= EspCommons::Image.new(:url => url, :description => description).parse_url
  end

  def as_json
    super(:only => [:url, :description], :methods => [:width, :height, :thumbnail])
  end
end
