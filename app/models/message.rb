class Message < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  default_scope order('created_at desc')
  paginates_per 1

  def self.filter_for(user)
    return where(:user_id=> user.id)
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

