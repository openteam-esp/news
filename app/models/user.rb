class User
  include Mongoid::Document

  field :name,  :type => String
  field :email, :type => String


  has_many :authentications

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

end
