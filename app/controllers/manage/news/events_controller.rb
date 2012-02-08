class Manage::News::EventsController < Manage::ApplicationController
  actions :show

  belongs_to :entry, :shallow => true
  layout 'manage/news/entry'

end
