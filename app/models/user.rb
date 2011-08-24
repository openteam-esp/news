class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :authentication
  has_many :events
  has_many :subscribes, :foreign_key => :subscriber_id
  has_many :messages
  has_and_belongs_to_many :roles, :after_add => :create_subscribe

  delegate :provider, :to => :authentication

  def to_s
    name
  end

  %w[corrector publisher].each do |role|
    define_method "#{role}?" do
      roles.map(&:kind).include?(role)
    end
  end

  def subscribed?(initiator)
    Subscribe.where(:subscriber_id => self, :initiator_id => initiator).any?
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

  private
    def create_subscribe(role)
      #role_events[role.kind.to_sym].each do |event|
        #self.subscribes.create!(:kind => event)
      #end
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
#

