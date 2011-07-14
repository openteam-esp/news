class EventsController < InheritedResources::Base
  belongs_to :entry

  actions :new, :create

  def create
    create! { root_path }
  end
end
