class EventsController < AuthorizedApplicationController
  actions :show

  belongs_to :entry, :shallow => true
  layout 'system/entry'

end
