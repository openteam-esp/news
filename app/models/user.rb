class User
  include Mongoid::Document

  attr_accessible :provider, :uid, :name, :email

  has_many :authentications

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

end
