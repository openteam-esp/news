class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :authentication
  has_many :events
  has_many :subscribes, :foreign_key => :subscriber_id
  has_many :messages

  delegate :provider, :to => :authentication

  has_enum :roles, [:corrector, :publisher], :multiple => true

  def to_s
    name
  end

  %w[corrector publisher].each do |role|
    define_method "#{role}?" do
      roles.map(&:to_s).include?(role)
    end
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

  def fresh_tasks
    types = ['Subtask']
    types << 'Review' if corrector?
    types << 'Publish' if publisher?
    Task.where(:type => types).where(:state => :fresh, :executor_id => [self.id, nil])
  end

  def processed_by_me_tasks
    Task.where(:state => :processing).where(:executor_id => self)
  end

  def initiated_by_me_tasks
    Task.where(:initiator_id => self).where("state <> 'pending'")
  end

end




# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  name                   :text
#  email                  :string(255)
#  encrypted_password     :string(128)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  roles                  :text
#

