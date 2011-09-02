class Legacy::Entry < ActiveRecord::Base
  establish_connection "legacy_#{Rails.env}"
  set_table_name "events"

  has_many :assets, :foreign_key => 'event_id'

  default_scope order('id desc')

  STATUS_TO_STATE = {
    :blank => :draft,
    :ready_to_publish => :awaiting_publication,
    :publish => :published
  }

  def body_as_html
    RDiscount.new(body.chomp).to_html
  end

  def state
    STATUS_TO_STATE[status.to_sym]
  end

  def channel_ids
    case target_id
    when 1 then [Channel.find_or_create_by_title('tomsk.gov.ru/ru/announces').id]
    when 2 then [Channel.find_or_create_by_title('tomsk.gov.ru/ru/news').id]
    else []
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

