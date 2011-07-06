News::Application.routes.draw do
  resources :entries

  devise_for :users

  resources :authentications

  match '/auth/:provider/callback' => 'authentications#create'

  root :to => "authentications#index"
end
