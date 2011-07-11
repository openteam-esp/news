class User
  include Mongoid::Document
  field :name,  :type => String
  field :email, :type => String


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :authentication
  has_many :events

  delegate :provider, :to => :authentication

  def to_s
    name
  end

end
