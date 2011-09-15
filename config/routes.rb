# encoding: utf-8

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
    resources :assets, :only => [:create, :destroy]
  end

  get '/:state/entries' => 'entries#index', :as => :scoped_entries, :constraints => {:state => /(draft|processing|trashed|published)/}

  get '/last_day/entries' => 'entries#index',
      :as => :last_day_entries,
      :defaults => {
                     'utf8' => '✓',
                     'entry_search[since_lt]' => I18n.l(Date.today),
                     'entry_search[since_gt]' => I18n.l(Date.today - 1)
                   }

  get '/last_week/entries' => 'entries#index',
      :as => :last_week_entries,
      :defaults => {
                     'utf8' => '✓',
                     'entry_search[since_lt]' => I18n.l(Date.today),
                     'entry_search[since_gt]' => I18n.l(Date.today - 1.week)
                   }

  get '/last_month/entries' => 'entries#index',
      :as => :last_month_entries,
      :defaults => {
                     'utf8' => '✓',
                     'entry_search[since_lt]' => I18n.l(Date.today),
                     'entry_search[since_gt]' => I18n.l(Date.today - 1.month)
                   }

  namespace :public do
    resources :entries, :only => [:index, :show]

    match 'channels/:channel_id/entries' => 'entries#index'
    match 'channels/:channel_id/entries/:id' => 'entries#show'
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


  get '/:kind/tasks' => 'tasks#index', :as => :tasks, :constraints => { :kind => /(fresh|processed_by_me|initiated_by_me)/ }

  root :to => 'roots#index'
end

