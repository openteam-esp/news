# encoding: utf-8
require 'spec_helper'

describe Asset do
  let(:image) do
    Image.new(:entry => draft).tap do |image|
      image.file = File.new(Rails.root.join "public/images/google_32.png")
      image.save!
    end
  end

  it "Должны проставляться размеры изображения" do
    image.file_width.should == 32
    image.file_height.should == 64
  end

  describe "пометка удаленным" do
    before do
      @asset = draft.assets.create!
      @asset.mark_as_deleted
    end
    it { @asset.should be_persisted }
    it { @asset.should be_deleted }
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
#

