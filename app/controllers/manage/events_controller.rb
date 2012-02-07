class Manage::EventsController < Manage::ApplicationController
  actions :show

  belongs_to :entry, :shallow => true
  layout 'manage/entry'

end
