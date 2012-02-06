# encoding: utf-8

require 'secondbase/model'
require 'rdiscount'

include ActionView::Helpers::TagHelper
include ActionView::Helpers::AssetTagHelper
include ActionView::Helpers::TextHelper


class LegacyEntry < SecondBase::Base

  self.table_name = "events"

  default_scope order('id desc')

  has_many :assets, :foreign_key => 'event_id', :class_name => 'LegacyAsset'

  %w[audio image attachment].each do | type |
    define_method "#{type.pluralize}" do
      assets.select(&:"#{type}?")
    end
  end

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
      entry.update_attribute :body, migrated_body + assets_html
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

    def add_image(file)

    end

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

