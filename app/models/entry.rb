class Entry
  include Mongoid::Document
  field :title,       :type => String
  field :annotation,  :type => String
  field :body,        :type => String
  field :since,       :type => DateTime
  field :until,       :type => DateTime

  has_and_belongs_to_many :channels
  has_many :events
end
