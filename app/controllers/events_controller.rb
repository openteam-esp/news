class EventsController < AuthorizedApplicationController
  actions :show

  layout 'system/entry'

  def show
    show! {
      @entry = @event.entry
      @versioned_entry = @event.versioned_entry
    }
  end
end
