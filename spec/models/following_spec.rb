# encoding: utf-8

require 'spec_helper'

describe Following do
  it { should belong_to(:follower) }
  it { should belong_to(:target) }
  it { should validate_presence_of(:follower_id) }
  it { should validate_presence_of(:target_id) }

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

