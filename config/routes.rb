# encoding: utf-8

News::Application.routes.draw do

  devise_for :users

  match '/auth/:provider/callback' => 'authentications#create'

  resources :authentications, :only => [:create, :destroy]

  resources :entries, :except => :index do
    member do
      get 'delete'
      post 'recycle'
    end
    get '/:type/' => 'assets#index', :constraints => { :type => /(assets|images|audios|videos|attachments)/ }
    resources :assets, :only => [:create, :destroy]
  end

  resources :events, :only => :show

  get '/:folder/entries' => 'entries#index',
      :as => :scoped_entries,
      :constraints => { :folder => /(draft|processing|deleted|published)/ }

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
    get '/channels/:channel_id/entries/:id' => "entries#show"
  end

  get '/assets/:id/:width-:height/:file_name' => Dragonfly[:assets].endpoint { |params, app|
    image = Image.find(params[:id])
    width = [params[:width].to_i, image.file_width].min
    height = [params[:height].to_i, image.file_height].min
    image.file.thumb("#{width}x#{height}")
  }, :as => :image, :format => false, :constraints => { :file_name => /.+?/ }

  get '/assets/:id/cropped/:file_name' => Dragonfly[:assets].endpoint { |params, app|
    image = Image.find(params[:id])
    image.file.thumb("118x100#")
  }, :as => :cropped_image, :format => false, :constraints => { :file_name => /.+?/ }

  get '/assets/:id/:file_name' => Dragonfly[:assets].endpoint { |params, app|
    app.fetch(Asset.find(params[:id]).file_uid)
  }, :as => :asset, :format => false, :constraints => { :file_name => /.+?/ }


  get '/:kind/tasks' => 'tasks#index',
      :as => :tasks,
      :constraints => { :kind => /(fresh|processed_by_me|initiated_by_me)/ }


  post '/tasks/:id/fire_event' => 'tasks#fire_event', :as => :fire_event_task

  resources :issues, :only => [] do
    resources :subtasks, :only => [:new, :create]
  end

  root :to => 'roots#index'
end

