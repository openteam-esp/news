class EntriesController < AuthorizedApplicationController
  actions :index, :show, :create, :edit, :update

  layout :sidebar_or_archive_layout

  has_scope :state
  has_scope :page, :default => 1, :only => :index

  has_searcher

  load_and_authorize_resource

  before_filter :lock_entry, :only => :edit

  def create
    create! { edit_entry_path(@entry) }
  end

  def update
    update! do |success, failure|
      success.html {
        if request.xhr?
          @entry.reload
          @entry.assets.build
          render :edit, :layout => false and return
        end
        redirect_to smart_resource_url
      }
    end
  end

  protected
    def collection
      get_collection_ivar || set_collection_ivar(search_and_paginate_collection)
    end

    def search_and_paginate_collection
      if params[:utf8]
        searcher.pagination = paginate_options
        searcher.results
      else
        end_of_association_chain.page
      end
    end

    def paginate_options(options={})
      {
        :page       => params[:page],
        :per_page   => 10
      }.merge(options)
    end

    def sidebar_or_archive_layout
      return 'archive' if current_scopes[:state] == 'published'
      'list'
    end

    def lock_entry
      @entry.lock
    end
end

