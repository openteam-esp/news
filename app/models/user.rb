class User
  include Mongoid::Document

  field :name,  :type => String
  field :email, :type => String

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :authentication

  delegate :provider, :to => :authentication

end
