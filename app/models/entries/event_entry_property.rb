class EventEntryProperty < ActiveRecord::Base
end
# == Schema Information
#
# Table name: event_entry_properties
#
#  id             :integer         not null, primary key
#  since          :datetime
#  until          :datetime
#  event_entry_id :integer
#  location       :text
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

