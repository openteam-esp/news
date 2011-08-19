class EventsController < AuthorizedApplicationController
  load_and_authorize_resource

  belongs_to :entry

  actions :create, :show

  def create
    create! { parent_path }
  end

end
