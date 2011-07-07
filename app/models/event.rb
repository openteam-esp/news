class Event
  include Mongoid::Document

  belongs_to :entry

  field :type, :type => String
  field :text, :type => String

  after_create :fire_entry_event

  private

    def fire_entry_event
      entry.fire_events type.to_sym unless type == 'created'
    end

end
