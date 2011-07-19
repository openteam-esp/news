class PublishedEntriesController < InheritedResources::Base
  defaults :resource_class => Entry
  load_resource

  belongs_to :channel

  actions :only => [:index, :show, :rss]

  def rss
    @channel = Channel.find(params[:channel_id])
    @published_entries = @channel.published_entries.limit(10)

    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end
