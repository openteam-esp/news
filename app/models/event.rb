class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, :type => String
  field :text, :type => String

  belongs_to :entry
  belongs_to :user

  after_create :fire_entry_event

  default_scope order_by([:created_at, :desc])

  private
    def fire_entry_event
      entry.fire_events type.to_sym if type != t('created') && type != 'updated'
    end
end
