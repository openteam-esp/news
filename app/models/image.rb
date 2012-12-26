# == Schema Information
#
# Table name: images
#
#  id          :integer          not null, primary key
#  url         :text
#  description :text
#  entry_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Image < ActiveRecord::Base
  attr_accessible :url, :description

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
