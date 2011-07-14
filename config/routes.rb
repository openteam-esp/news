News::Application.routes.draw do
  devise_for :users

  match '/auth/:provider/callback' => 'authentications#create'

  resources :authentications, :only => [:create, :destroy]

  resources :folders, :only => [] do
    resources :entries do
      resources :events, :only => [:new, :create]
      get :to_trash, :on => :member
    end
  end

  match '/' => 'entries#index', :defaults => {:folder_id => 'inbox'}, :as => :root
end
