class EventsController < InheritedResources::Base
  load_and_authorize_resource

  belongs_to :entry

  actions :create

  def create
    create! do |success, failure|
      success.html { redirect_to root_path }
      failure.html { redirect_to(folder_entry_path(@event.entry.folder, @event.entry),
                                 :alert => ::I18n.t("Got error when #{@event.type}. You must fill required fields.")) }
    end
  end
end
