class Recipient
  include Mongoid::Document

  field :email,       :type => String
  field :description, :type => String
  field :active,      :type => Boolean

  default_scope where(:active => true)

  belongs_to :channel
end
