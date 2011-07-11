class Event
  include Mongoid::Document
  field :type, :type => String
  field :text, :type => String

  belongs_to :entry
  belongs_to :user

  after_create :fire_entry_event

  private

    def fire_entry_event
      entry.fire_events type.to_sym unless type == 'created'
    end

end
