class Manage::News::EventsController < Manage::ApplicationController
  actions :show
  belongs_to :entry, :shallow => true

  has_scope :with_serialized_entry, :default => true, :type => :boolean

  layout 'manage/news/entry'

end
