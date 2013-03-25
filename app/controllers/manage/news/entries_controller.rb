class Manage::News::EntriesController < Manage::ApplicationController
  actions :index, :show, :create, :edit, :update, :destroy
  custom_actions :resource => [:revivify, :unlock]

  before_filter :set_current_user, :except => [:index, :show]

  layout :resolve_layout

  has_scope :folder do |controller, scope, value|
    scope.folder(value, controller.current_user)
  end

  has_scope :period, :only => :index do |controller, scope, value|
    scope.since_greater_than(1.send(value).ago.change(:hour => 0))
  end

  has_scope :page, :default => 1, :only => :index

  has_scope :per, :default => true, :only => :index, :type => :boolean do |controller, scope|
    scope.per(7)
  end

  has_scope :load_associations, :default => true, :type => :boolean, :only => :index do |controller, scope, value|
    scope.includes(:images).includes(:initiator)
  end

  def destroy
    resource.move_to_trash
    redirect_to manage_news_root_path
  end

  def edit
    edit! do
      resource.lock
    end
  end

  def create
    create! { edit_manage_news_entry_path(resource) }
  end

  def revivify
    revivify! do
      resource.revivify
      redirect_to manage_news_entry_path(resource) and return
    end
  end

  def update
    update! do |success, failure|
      success.html {
        resource.unlock
        if request.xhr?
          resource.reload
          render :edit, :layout => false and return
        end
        redirect_to manage_news_entry_path(resource.id) and return
      }
    end
  end

  def unlock
    unlock! do
      @entry.unlock
      redirect_to manage_news_entry_path(resource) and return
    end
  end

  protected
    ENTRY_CLASSES = {
      'announcement_entry'=> AnnouncementEntry,
      'event_entry'=> EventEntry,
      'news_entry'=> NewsEntry,
    }

    def class_of_resource
      ENTRY_CLASSES[params[:type]]
    end

    def build_resource
      @entry ||= class_of_resource.new do |entry|
        entry.current_user = current_user
      end
    end

    def resolve_layout
      return 'archive' if current_scopes[:state] == 'published'
      return 'manage/news/entry' if ['show', 'edit', 'update'].include?(action_name)
      'manage/news/list'
    end

    def set_current_user
      resource.set_current_user(current_user)
    end

end

