class Following < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User'
  belongs_to :target, :class_name => 'User'
  validates_presence_of :follower_id, :target_id
  validates_uniqueness_of :target_id, :scope => :follower_id
end

# == Schema Information
#
# Table name: followings
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  target_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

