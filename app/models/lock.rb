# == Schema Information
#
# Table name: locks
#
#  id         :integer          not null, primary key
#  entry_id   :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lock < ActiveRecord::Base
  attr_accessible :user

  belongs_to :entry
  belongs_to :user
end
