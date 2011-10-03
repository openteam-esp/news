# encoding: utf-8

require 'spec_helper'

describe Following do
  it { should belong_to(:follower) }
  it { should belong_to(:target) }
  it { should validate_presence_of(:follower_id) }
  it { should validate_presence_of(:target_id) }

end
