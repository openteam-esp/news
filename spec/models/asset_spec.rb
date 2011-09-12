# encoding: utf-8

require 'spec_helper'

describe Asset do
  it "Должен автомагически создавать ассет нужного типа для видео" do
    expect { Asset.new(:file_mime_type => 'video/flv').save :validate => false }.to change{Video.count}.by(1)
  end
  it "Должен автомагически создавать ассет нужного типа для аудио" do
    expect { Asset.new(:file_mime_type => 'audio/ogg').save :validate => false }.to change{Audio.count}.by(1)
  end
  it "Должен автомагически создавать ассет нужного типа для картинок" do
    expect { Asset.new(:file_mime_type => 'image/jpeg').save :validate => false }.to change{Image.count}.by(1)
  end
  it "Должен автомагически создавать ассет нужного типа для остальных файлов" do
    expect { Asset.new(:file_mime_type => 'application/pdf').save :validate => false }.to change{Attachment.count}.by(1)
  end
  it "Должны проставляться размеры изображения" do
    entry = create_draft_entry_with_asset
    image = entry.images.first
    image.file = File.new(Rails.root.join "public/images/google_32.png")
    image.save
    image.file_width.should == 32
    image.file_height.should == 64
  end
end






# == Schema Information
#
# Table name: assets
#
#  id              :integer         not null, primary key
#  type            :string(255)
#  entry_id        :integer
#  file_name       :string(255)
#  file_mime_type  :string(255)
#  file_size       :integer
#  file_updated_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  file_uid        :string(255)
#  file_width      :integer
#  file_height     :integer
#  legacy_id       :integer
#  description     :text
#

