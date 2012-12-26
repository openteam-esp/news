class Lock < ActiveRecord::Base
  attr_accessible :user

  belongs_to :entry
  belongs_to :user
end
