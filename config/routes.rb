News::Application.routes.draw do
  devise_for :users

  match '/auth/:provider/callback' => 'authentications#create'

  resources :authentications, :only => [:create, :destroy]

  resources :entries do
    resources :events, :only => [:new, :create]
  end

  root :to => "entries#index"
end
