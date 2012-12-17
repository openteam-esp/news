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
#  created_at  :datetime         not null
#  follower_id :integer
#  id          :integer          not null, primary key
#  target_id   :integer
#  updated_at  :datetime         not null
#

