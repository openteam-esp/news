class EventsController < ApplicationController
  inherit_resources

  belongs_to :entry

  actions :new, :create

  def create
    create! { root_path }
  end

end
