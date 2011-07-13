class Folder
  include Mongoid::Document
  field :title, :type => String
  has_many :entries
end
