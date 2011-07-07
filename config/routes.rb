News::Application.routes.draw do

  resources :entries do
    resources :events, :only => [:new, :create]
  end

  devise_for :users

  resources :authentications

  match '/auth/:provider/callback' => 'authentications#create'

  root :to => "authentications#index"
end
