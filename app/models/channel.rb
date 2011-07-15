class Channel
  include Mongoid::Document

  field :title, :type => String

  has_many :recipients
end
