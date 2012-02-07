class User < ActiveRecord::Base
  attr_accessible :name, :email, :nickname, :name, :first_name, :last_name, :location, :description, :image, :phone, :urls, :raw_info, :uid

  validates_presence_of :uid

  has_many :followings, :foreign_key => :follower_id
  has_many :followers_following,  :foreign_key => :target_id, :order => :follower_id, :class_name => 'Following'
  has_many :followers,  :through => :followers_following
  has_many :permissions

  default_value_for :sign_in_count, 0

  devise :omniauthable, :trackable, :timeoutable

  searchable do
    integer :uid
    text :term do [name, email, nickname].join(' ') end
    integer :permissions_count do permissions.count end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current_id
    current.id if current
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  Permission.enums[:role].each do | role |
    define_method "#{role}_of?" do |context|
      permissions.for_role(role).for_context_and_ancestors(context).exists?
    end
    define_method "#{role}?" do
      permissions.for_role(role).exists?
    end
  end

  def contexts
    permissions.map(&:context).uniq
  end

  def contexts_tree
    contexts.flat_map{|c| c.respond_to?(:subtree) ? c.subtree : c}
            .uniq
            .flat_map{|c| c.respond_to?(:subcontexts) ? [c] + c.subcontexts : c }
            .uniq
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

