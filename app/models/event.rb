class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, :type => String
  field :text, :type => String

  embedded_in :entry

  belongs_to :user

  after_create :fire_entry_event

  private
    def fire_entry_event
      entry.fire_events type.to_sym if type != 'created' && type != 'updated'
    end
end
