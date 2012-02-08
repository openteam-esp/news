class Manage::News::EntriesController < Manage::ApplicationController
  actions :index, :show, :create, :edit, :update, :destroy
  custom_actions :resource => [:revivify, :unlock]

  before_filter :set_current_user, :except => [:index, :show]

  layout :resolve_layout

  has_scope :folder do | controller, scope, value |
    scope.folder(value, controller.current_user)
  end

  has_scope :page, :default => 1, :only => :index

  has_searcher

  def destroy
    resource.move_to_trash
    redirect_to manage_news_root_path
  end

  def edit
    edit! do
      @entry.lock
    end
  end

  def create
    resource.initiator = current_user
    create! { edit_manage_news_entry_path(resource) }
  end

  def revivify
    revivify! do
      resource.revivify
      redirect_to smart_resource_url and return
    end
  end

  def update
    update! do |success, failure|
      success.html {
        if request.xhr?
          @entry.reload
          render :edit, :layout => false and return
        end
        redirect_to smart_resource_url and return
      }
    end
  end

  def unlock
    unlock! do
      @entry.unlock
      redirect_to smart_resource_url and return
    end
  end

  protected
    def collection
      get_collection_ivar || set_collection_ivar(search_and_paginate_collection)
    end

    def search_and_paginate_collection
      if params[:period]
        searcher.order_by = 'updated_at desc'
        searcher.updated_at_gt = 1.send(params[:period]).ago.to_date
      end
      if params[:utf8] || params[:period]
        searcher.per_page = paginate_options[:per_page]
        searcher.pagination.merge! paginate_options
        searcher.results
      else
        end_of_association_chain.page(paginate_options[:page]).per(paginate_options[:per_page])
      end
    end

    def paginate_options()
      {
        :page       => params[:page],
        :per_page   => [[(params[:per_page] || 10).to_i,  1].max, 10].min
      }
    end

    def resolve_layout
      return 'archive' if current_scopes[:state] == 'published'
      return 'manage/news/entry' if ['show', 'edit'].include?(action_name)
      'manage/news/list'
    end

    def set_current_user
      resource.current_user = current_user
    end
end

