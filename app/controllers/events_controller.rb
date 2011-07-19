class EventsController < InheritedResources::Base
  load_and_authorize_resource

  belongs_to :entry

  actions :create

  def create
    create! { root_path }
  end
end
