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

  resources :entries, :only => [:show, :create, :edit] do
    get 'page/:page', :action => :index, :on => :collection
    resources :events, :only => [:create, :show]
    resources :assets, :only => [:create, :destroy]
  end

  match '/:state/entries' => 'entries#index', :as => :entries_path

  root :to => 'roots#index'
end

