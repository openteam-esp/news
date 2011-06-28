class Entry
  include Mongoid::Document
  field :title,       :type => String
  field :body,        :type => String
  field :extended,    :type => String
  field :released_at, :type => DateTime
end
