class Subscribe < ActiveRecord::Base
  belongs_to :subscriber, :class_name => 'User'

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  has_enum :kind, Entry.state_machine.events.map(&:name)
end
