# encoding: utf-8

require 'rdiscount'
require Rails.root.join('app/models/entry')
require Rails.root.join('app/models/asset/asset')
require Rails.root.join('app/models/asset/image')
require Rails.root.join('app/models/asset/audio')
require Rails.root.join('app/models/asset/video')
require Rails.root.join('app/models/asset/attachment')

include ActionView::Helpers::TagHelper
include ActionView::Helpers::AssetTagHelper
include ActionView::Helpers::TextHelper
include Rails.application.routes.url_helpers

class Asset
  attr_accessor :description
  def path
    asset_path id, file_name
  end
  def to_html
    content_tag :a, self.to_s, :target => '_blank', :href => path,
  end
  def to_s
    description
  end
end

class Image
  def to_s
    height = 150
    if file_height > height
      ratio = height / file_height.to_f
      width = (file_width * ratio).to_i
    else
      height = file_height
      width = file_width
    end
    tag :img, :src => image_path(id, width, height, file_name), :alt => description, :width => width, :height => height
  end
end

class Audio
  alias :old_to_html :to_html
  def to_html
    content_tag(:audio, deprecated_browser_message, :src => path, :controls => true)
  end
  def deprecated_browser_message
    %Q{Ваш браузер не поддерживает тэг audio. Вы можете скачать файл: #{old_to_html}}.html_safe
  end
end


class Entry
  def assets_html
    "".tap do | assets_html |
      attachments.each do | attachment |
        assets_html << content_tag(:p, attachment.to_html)
      end
      audios.each do | audio |
        assets_html << content_tag(:p, audio.to_html)
      end
      if images.any?
        assets_html << content_tag(:p, images.map(&:to_html).join("\n").html_safe)
      end
    end
  end
end

class LegacyEntry < ActiveRecord::Base

  establish_connection "legacy_#{Rails.env}"

  set_table_name "events"

  has_many :legacy_assets, :foreign_key => 'event_id'

  default_scope order('id desc')

  def migrated_body
    RDiscount.new(body.chomp).to_html
  end

  def migrated_annotation
    simple_format annotation.clone
  end

  def channels
    case target_id
    when 1 then [Channel.find_or_create_by_title('tomsk.gov.ru/ru/announces')]
    when 2 then [Channel.find_or_create_by_title('tomsk.gov.ru/ru/news')]
    else []
    end
  end

  def self.migrate(logger=nil)
    LegacyEntry.record_timestamps = false
    LegacyEntry.find_in_batches(:batch_size => 100) do | batch |
      logger.try :print, '.'
      batch.each do | legacy_entry |
        legacy_entry.migrate
      end
    end
  end

  def migrate
    User.current = initiator
    Entry.find_or_initialize_by_legacy_id(id).tap do |entry|
      entry.title         = title
      entry.annotation    = migrated_annotation
      entry.created_at    = created_at
      entry.since         = date_time
      entry.until         = end_date_time
      entry.save :validate => false
      entry.channels      = channels
      legacy_assets.each do | legacy_asset |
        asset = Asset.find_or_initialize_by_legacy_id legacy_asset.id
        asset.entry = entry
        asset.file = File.open(legacy_asset.file.path)
        asset.description = legacy_asset.description
        asset.save :validate => false
        entry.assets << asset
      end
      entry.update_attribute :body, migrated_body + entry.assets_html
      entry.prepare.complete!
      if status.to_s != 'blank'
        entry.review.accept!
        entry.review.complete!
      end
      if status.to_s == 'publish'
        entry.publish.accept!
        entry.publish.complete!
      end
      entry.update_attributes :updated_at => updated_at
    end
  end

  private
    def initiator
      @initiator ||= User.find_or_initialize_by_email('migrator@pressa.tomsk.gov.ru').tap do | user |
                        user.name = 'Мигратор'
                        user.roles = %w[corrector publisher]
                        user.save! :validate => false
                      end
    end
end

# == Schema Information
#
# Table name: events
#
#  id            :integer         not null, primary key
#  title         :text
#  annotation    :text
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#  status        :string(255)
#  target_id     :integer
#  date_time     :datetime
#  end_date_time :datetime
#

