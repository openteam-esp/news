class Message < ActiveRecord::Base
  def self.filter_for(user)
    return where(:user => user)
  end
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

