# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  uid                :string(255)
#  name               :text
#  email              :text
#  nickname           :text
#  first_name         :text
#  last_name          :text
#  location           :text
#  description        :text
#  image              :text
#  phone              :text
#  urls               :text
#  raw_info           :text
#  sign_in_count      :integer
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class User < ActiveRecord::Base
  sso_auth_user

  has_many :followings, :foreign_key => :follower_id
  has_many :followers_following,  :foreign_key => :target_id, :order => :follower_id, :class_name => 'Following'
  has_many :followers,  :through => :followers_following

  has_many :root_channels, :class_name => 'Channel', :through => :permissions, :source => :context, :source_type => 'Channel'

  def following_for(target)
    followings.where(:target_id => target).first
  end

  def to_s
    name
  end

  %w[initiator corrector publisher manager].each do |role|
    define_method "#{role}_of?" do |entry|
      Channel.subtree_for(self, :role => role).joins(:entries).where(:entries => {:id => entry.id}).any?
    end
  end

  %w[initiator corrector publisher].each do |role|
    alias_method "old_#{role}_of?", "#{role}_of?"
    define_method "#{role}_of?" do |entry|
      send("old_#{role}_of?", entry) || manager_of?(entry)
    end
  end

  def is_administrator?
    self.permissions.map(&:role).include?('administrator')
  end

end
