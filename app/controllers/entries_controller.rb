class EntriesController < InheritedResources::Base
  before_filter :authenticate_user!, :except => :rss

  belongs_to :folder, :finder => :find_by_title

  load_and_authorize_resource

  def rss
    @entries = Entry.where(:state => :published)
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end
