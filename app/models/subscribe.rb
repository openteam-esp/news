class Subscribe < ActiveRecord::Base
  belongs_to :subscriber, :class_name => 'User'

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  has_enum :kind, Entry.all_events
end

# == Schema Information
#
# Table name: subscribes
#
#  id            :integer         not null, primary key
#  subscriber_id :integer
#  initiator_id  :integer
#  entry_id      :integer
#  kind          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

