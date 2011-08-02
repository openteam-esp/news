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

  resources :folders, :only => [] do
    resources :entries do
      resources :events, :only => :create
    end
  end

  root :to => 'roots#index'
end
