class User < ActiveRecord::Base
  esp_auth_user

  has_many :followings, :foreign_key => :follower_id
  has_many :followers_following,  :foreign_key => :target_id, :order => :follower_id, :class_name => 'Following'
  has_many :followers,  :through => :followers_following

  def following_for(target)
    followings.where(:target_id => target).first
  end

end

# == Schema Information
#
# Table name: users
#
#  created_at         :datetime         not null
#  current_sign_in_at :datetime
#  current_sign_in_ip :string(255)
#  description        :text
#  email              :text
#  first_name         :text
#  id                 :integer          not null, primary key
#  image              :text
#  last_name          :text
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string(255)
#  location           :text
#  name               :text
#  nickname           :text
#  phone              :text
#  raw_info           :text
#  sign_in_count      :integer
#  uid                :string(255)
#  updated_at         :datetime         not null
#  urls               :text
#

