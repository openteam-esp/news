#encoding: utf-8

class EventEntryProperty < ActiveRecord::Base

  attr_accessible :since, :until, :location

  belongs_to :entry

  validates_presence_of :since, :until

  def interval
    if since_date == until_date
      if since_time == until_time
        if since_time == "00:00"
          since_date
        else
          "#{since_date} в #{since_time}"
        end
      else
        "#{since_date} с #{since_time} по #{until_time}"
      end
    else
      "с #{since_date} по #{until_date}"
    end
  end

  def as_json(options={})
    super(options.merge(:methods => :interval))
  end

  private
    %w[since until].each do |field|
      define_method "localized_#{field}" do
        I18n.l(self.send(field))
      end
      define_method "#{field}_date" do
        self.send("localized_#{field}").split(' ').first
      end
      define_method "#{field}_time" do
        self.send("localized_#{field}").split(' ').second
      end
    end
end

# == Schema Information
#
# Table name: event_entry_properties
#
#  id         :integer          not null, primary key
#  since      :datetime
#  until      :datetime
#  entry_id   :integer
#  location   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

