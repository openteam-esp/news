# encoding: utf-8
class Legacy::Entry < ActiveRecord::Base
  establish_connection "legacy_#{Rails.env}"
  set_table_name "events"

  has_many :assets, :foreign_key => 'event_id'

  default_scope order('id desc')

  def body_as_html
    RDiscount.new(body.chomp).to_html
  end

  def channel_ids
    case target_id
    when 1 then [Channel.find_or_create_by_title('tomsk.gov.ru/ru/announces').id]
    when 2 then [Channel.find_or_create_by_title('tomsk.gov.ru/ru/news').id]
    else []
    end
  end

  def migrate
    User.current = initiator
    entry = ::Entry.find_or_initialize_by_legacy_id(id)
    entry.title         = title.squish
    entry.annotation    = annotation.squish
    entry.body          = body_as_html
    entry.since         = date_time
    entry.until         = end_date_time
    entry.created_at    = created_at
    entry.save :validate => false
    entry.channel_ids   = channel_ids
    entry.prepare.complete!
    if status != 'blank'
      entry.review.reload.accept!
      entry.review.reload.complete!
    end
    if status == 'publish'
      entry.publish.reload.accept!
      entry.publish.reload.complete!
    end
    entry.update_attribute :updated_at, updated_at
    assets.each do | legacy_asset |
      asset = entry.assets.find_or_initialize_by_legacy_id legacy_asset.id
      asset.file = File.open(legacy_asset.file.path)
      asset.description = legacy_asset.description
      asset.save :validate => false
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

