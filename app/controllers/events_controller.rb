class EventsController < AuthorizedApplicationController

  belongs_to :entry

  load_and_authorize_resource

  actions :create, :show

  def create
    create! { parent_path }
  end

end
