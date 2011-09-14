News::Application.routes.draw do

  devise_for :users

  match '/auth/:provider/callback' => 'authentications#create'

  resources :authentications, :only => [:create, :destroy]

  resources :messages do
    get 'page/:page', :action => :index, :on => :collection
  end

  resources :channels, :only => [:index, :show] do
    resources :recipients, :except => :show

    resources :published_entries, :only => [:index, :show] do
      get 'page/:page', :action => :index, :on => :collection
    end

    match '/rss' => 'published_entries#rss'
  end

  match '/subscribe/:entry_id' => 'subscribes#create', :as => :subscribe
  match '/subscribe/:entry_id/delete' => 'subscribes#destroy', :as => :delete_subscribe

  resources :entries, :only => [:show, :create, :edit, :index] do
    get 'page/:page', :action => :index, :on => :collection
    resources :events, :only => [:create, :show]
    resources :assets, :only => [:create, :destroy]
  end

  get '/assets/:id/:width-:height/:filename' => Dragonfly[:images].endpoint { |params, app|
    image = Image.find(params[:id])
    width = [params[:width].to_i, image.file_width].min
    height = [params[:height].to_i, image.file_height].min
    image.file.thumb("#{width}x#{height}")
  }, :as => :image, :constraints => { :filename => /.+?/ }

  get '/assets/:id/:filename' => Dragonfly[:images].endpoint { |params, app|
    app.fetch(Asset.find(params[:id]).file_uid)
  }, :as => :asset, :constraints => { :filename => /.+?/ }

  get '/:state/entries' => 'entries#index', :as => :entries_path

  get '/:kind/tasks' => 'tasks#index', :as => :tasks, :constraints => { :kind => /(fresh|my|other)/ }

  root :to => 'roots#index'
end

