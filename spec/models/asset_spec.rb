# encoding: utf-8

require 'spec_helper'

describe Asset do
  it "Должен автомагически создавать ассет нужного типа для видео" do
    expect { Asset.new(:file_content_type => 'video/flv').save :validate => false }.to change{Video.count}.by(1)
  end
  it "Должен автомагически создавать ассет нужного типа для аудио" do
    expect { Asset.new(:file_content_type => 'audio/ogg').save :validate => false }.to change{Audio.count}.by(1)
  end
  it "Должен автомагически создавать ассет нужного типа для картинок" do
    expect { Asset.new(:file_content_type => 'image/jpeg').save :validate => false }.to change{Image.count}.by(1)
  end
  it "Должен автомагически создавать ассет нужного типа для остальных файлов" do
    expect { Asset.new(:file_content_type => 'application/pdf').save :validate => false }.to change{Attachment.count}.by(1)
  end
end

# == Schema Information
#
# Table name: assets
#
#  id                :integer         not null, primary key
#  type              :string(255)
#  entry_id          :integer
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

