class Entry
  include Mongoid::Document
  field :title,       :type => String
  field :annotation,  :type => String
  field :body,        :type => String
  field :since,       :type => DateTime
  field :until,       :type => DateTime

  has_and_belongs_to_many :channels
  has_many :events

  validates_presence_of :body

  after_create :create_event

  private
    def create_event
      events.create! :type => 'created'
    end
end
