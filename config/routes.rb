News::Application.routes.draw do

  devise_for :users

  match '/auth/:provider/callback' => 'authentications#create'

  resources :authentications, :only => [:create, :destroy]

  resources :recipients

  resources :messages

  resources :channels, :only => [:index, :show] do
    resources :published_entries, :only => [:index, :show]
    match '/rss' => 'published_entries#rss'
  end

  match '/subscribe/:entry_id' => 'subscribes#create', :as => :subscribe
  match '/subscribe/:entry_id/delete' => 'subscribes#destroy', :as => :delete_subscribe

  resources :folders, :only => [] do
    resources :entries do
      resources :events, :only => :create do
        resources :versions, :only => :show
      end
    end
  end

  root :to => 'roots#index'
end
