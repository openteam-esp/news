class Event
  include Mongoid::Document

  belongs_to :entry

  field :type, :type => String
  field :text, :type => String

end
