class User < ActiveRecord::Base

  esp_authable

  has_many :followings, :foreign_key => :follower_id
  has_many :followers_following,  :foreign_key => :target_id, :order => :follower_id, :class_name => 'Following'
  has_many :followers,  :through => :followers_following

  def self.current
    Thread.current[:user]
  end

  def self.current_id
    current.id if current
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def fresh_tasks
    types = ['Subtask']
    types << 'Review' if corrector?
    types << 'Publish' if publisher?
    Task.not_deleted.where(:type => types).where(:state => :fresh).where(['executor_id IS NULL OR executor_id = ?', self.id])
  end

  def processed_by_me_tasks
    Task.not_deleted.processing.where(:executor_id => self.id)
  end

  def initiated_by_me_tasks
    Task.not_deleted.where(:initiator_id => self.id).where("state <> 'pending'")
  end

  def following_for(target)
    followings.where(:target_id => target).first
  end

end



# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
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
#  sign_in_count      :integer         default(0)
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

