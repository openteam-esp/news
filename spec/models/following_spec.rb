# encoding: utf-8
# == Schema Information
#
# Table name: followings
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  target_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


require 'spec_helper'

describe Following do
  it { should belong_to(:follower) }
  it { should belong_to(:target) }
  it { should validate_presence_of(:follower_id) }
  it { should validate_presence_of(:target_id) }

end
