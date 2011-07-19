class Recipient
  include Mongoid::Document

  field :email,       :type => String
  field :description, :type => String
  field :active,      :type => Boolean

  validates_presence_of :email
  validates_uniqueness_of :email

  default_scope where(:active => true)

  belongs_to :channel
end
