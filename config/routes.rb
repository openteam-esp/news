# encoding: utf-8

News::Application.routes.draw do

  resources :entries, :except => :index do
    member do
      get 'delete'
      post 'revivify'
      post 'unlock'
    end
    get '/:type/' => 'assets#index', :constraints => { :type => /(assets|images|audios|videos|attachments)/ }
    resources :assets, :only => [:create, :destroy]
  end

  resources :events, :only => :show

  get '/:folder/entries' => 'entries#index',
      :as => :scoped_entries,
      :constraints => { :folder => /(draft|processing|deleted|published)/ }

  get '/last_:period/entries' => 'entries#index', :constraints => {:period => /(day|week|month)/}, :as => :archive

  namespace :public do
    resources :entries, :only => [:index, :show]

    resources :channels, :only => [] do
      resources :entries, :only => [:index, :show]
    end
  end

  get '/:folder/tasks' => 'tasks#index',
      :as => :tasks,
      :constraints => { :folder => /(fresh|processed_by_me|initiated_by_me)/ }


  post '/tasks/:id/fire_event' => 'tasks#fire_event', :as => :fire_event_task

  resources :issues, :only => [] do
    resources :subtasks, :only => [:new, :create]
  end

  resources :followings, :only => [:create, :destroy]

  mount ElVfsClient::Engine => '/'

  root :to => 'roots#index'
end

