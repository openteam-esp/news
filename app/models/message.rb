class Message < ActiveRecord::Base
end

# == Schema Information
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  event_id   :integer
#  user_id    :integer
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#

