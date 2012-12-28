# encoding: utf-8

News::Application.routes.draw do

  namespace :manage do
    namespace :news do

      resources :entries, :except => :index do
        member do
          post :revivify
          post :unlock
        end
        get '/:type/' => 'assets#index', :constraints => { :type => /(assets|images|audios|videos|attachments)/ }
        resources :assets, :only => [:create, :destroy]
      end

      resources :tasks, :only => :update

      resources :issues, :only => [] do
        resources :subtasks, :only => [:new, :create]
      end

      resources :events, :only => :show

      resources :followings, :only => [:create, :destroy]

      get '/:folder/entries' => 'entries#index',
        :constraints => {:folder => /(draft|processing|deleted|published)/},
        :as => :scoped_entries

      get '/last_:period/entries' => 'entries#index',
        :constraints => {:period => /(day|week|month)/},
        :defaults => { :folder => 'published' },
        :as => :archive

      get '/:folder/tasks' => 'tasks#index',
        :constraints => {:folder => /(fresh|processed_by_me|initiated_by_me)/},
        :as => :tasks

      root :to => 'tasks#index', :folder => 'fresh'

    end

    resources :channels, :except => :show

    root :to => 'news/tasks#index', :folder => 'fresh'
  end

  resources :entries, :only => [:index, :show]

  resources :channels, :only => [:show] do
    resources :entries, :only => [:index, :show]
  end

  resources :channels, :only => [:index], :format => :json

  root :to => 'entries#index'

  mount ElVfsClient::Engine => '/'

end

