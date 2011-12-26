# encoding: utf-8

require 'secondbase/model'

include ActionView::Helpers::TagHelper
include ActionView::Helpers::AssetTagHelper
include ActionView::Helpers::TextHelper

class LegacyAsset < SecondBase::Base

  set_inheritance_column :_type

  set_table_name "attachments"

  default_scope order(:id)

  belongs_to :entry, :class_name => 'LegacyEntry', :foreign_key => 'event_id'

  delegate :image?, :attachment?, :audio?, :to => :mime_group

  def mime_group
    @mime_group ||= begin
                      group = file_content_type.split('/').first
                      group = %w[audio image].include?(group) ? group : 'attachment'
                      ActiveSupport::StringInquirer.new(group)
                    end
  end

  def file
    if Rails.env.test?
      File.new(Rails.root.join "spec/fixtures/#{file_file_name}")
    else
      File.new(Rails.root.join ".legacy/#{id}/original/#{file_file_name}")
    end
  end

  def to_html
    send "#{mime_group}_html"
  end

  private

    def attachment_html(description=description)
      content_tag :a, description, :target => '_blank', :href => path
    end

    def audio_html
      deprecated_browser_message = %Q{Ваш браузер не поддерживает тэг audio. Вы можете скачать файл: #{attachment_html}}.html_safe
      content_tag(:audio, deprecated_browser_message, :src => path, :controls => true)
    end

    def image_html
      attachment_html image_tag
    end

    def image_tag
      height = 150
      if file_height > height
        ratio = height / file_height.to_f
        width = (file_width * ratio).to_i
      else
        height = file_height
        width = file_width
      end
      tag :img, :src => resized_image_path(width, height), :alt => description, :width => width, :height => height
    end

    def resized_image_path(width, height)
      path.gsub(%r{(/files/\d+/)}, "\\1#{width}-#{height}/")
    end

    def path
      @path ||= vfs_file[:url]
    end

    def vfs_file
      @vfs_file ||= ElVfsClient::Client.new.upload(file)
    end

    def file_height
      vfs_file[:height]
    end

    def file_width
      vfs_file[:width]
    end
end


# == Schema Information
#
# Table name: attachments
#
#  id                :integer         not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  event_id          :integer
#  description       :text
#  type              :string
#

