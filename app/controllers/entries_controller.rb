class EntriesController < ApplicationController
  inherit_resources

  respond_to :html, :json, :rss

  actions :index, :show

  layout :resolve_layout

  has_scope :published, :type => :boolean, :default => true
  has_scope :not_deleted, :type => :boolean, :default => true

  belongs_to :channel, :optional => true

  helper_method :available_channels

  def show
    resource.resize_image(params[:entries_params]) if params[:entries_params]
    resource.find_more_like_this(params[:more_like_this].merge(:channel_id => params[:channel_id])) if params[:more_like_this]
    show!
  end

  protected
    def resolve_layout
      action_name == 'show' ? 'public/entry' : 'public/list'
    end

    def collection
      get_collection_ivar || set_collection_ivar(paginated_collection_with_resized_image_urls)
    end

    def search_and_paginate_collection
      if params[:utf8]
        searcher.deleted = false
        searcher.channel_ids = [params[:channel_id]] if params[:channel_id]
        searcher.per_page = paginate_options[:per_page]
        searcher.pagination.merge! paginate_options
        results = searcher.results
        headers['X-Current-Page'] = results.current_page.to_s
        headers['X-Total-Pages'] = results.total_pages.to_s
        headers['X-Total-Count'] = results.total_count.to_s
        results
      else
        end_of_association_chain.page(paginate_options[:page]).per(paginate_options[:per_page])
      end
    end

    def paginated_collection_with_resized_image_urls
      entries = search_and_paginate_collection
      entries.each{|entry| entry.resize_image(params[:entries_params])} if params[:entries_params]
      entries
    end

    def paginate_options
      {
        :page       => params[:page],
        :per_page   => [[(params[:per_page] || 10).to_i,  1].max, 10].min
      }
    end

    def available_channels
      Channel.where("entry_type is not null")
    end
end
