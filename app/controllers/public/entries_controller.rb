# encoding: utf-8

class Public::EntriesController < ApplicationController
  inherit_resources

  respond_to :html, :xml, :json

  actions :index, :show

  layout :resolve_layout

  belongs_to :channel, :optional => true

  protected
    def resolve_layout
      return 'public/entry' if action_name == 'show'
      'public/list'
    end

    def collection
      get_collection_ivar || set_collection_ivar(search_and_paginate_collection)
    end

    def search_and_paginate_collection
      if params[:utf8]
        searcher.channel_ids = [params[:channel_id]] if params[:channel_id]
        searcher.per_page = paginate_options[:per_page]
        searcher.pagination.merge! paginate_options
        results = searcher.results
        headers['X-Total-Count'] = results.total_count.to_s
        headers['X-Total-Pages'] = results.total_pages.to_s
        results
      else
        end_of_association_chain.published.page(paginate_options[:page]).per(paginate_options[:per_page])
      end
    end

    def paginate_options
      {
        :page       => params[:page],
        :per_page   => [[(params[:per_page] || 10).to_i,  1].max, 10].min
      }
    end
end
