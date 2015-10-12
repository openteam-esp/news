# encoding: utf-8

require 'spec_helper'

describe User do

  it { should have_many(:followers) }
  it { should have_many(:followings) }

end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  uid                :string(255)
#  name               :string(255)
#  email              :string(255)
#  first_name         :string(255)
#  last_name          :string(255)
#  raw_info           :text
#  sign_in_count      :integer
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

