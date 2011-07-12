Settings.read Rails.root.join 'config', 'settings.yml'
Settings.define 'hoptoad.api_key',                :env_var => 'HOPTOAD_API_KEY'
Settings.define 'hoptoad.host',                   :env_var => 'HOPTOAD_HOST'
#Settings.define 'secret_token',                   :env_var => 'SECRET_TOKEN',       :required => true
Settings.define 'mongo.url',                      :env_var => 'MONGO_URL'
Settings.define 'omniauth.twitter.app_key',       :env_var => 'TWITTER_APP_KEY',        :required => true
Settings.define 'omniauth.twitter.app_secret',    :env_var => 'TWITTER_APP_SECRET',     :required => true
Settings.define 'omniauth.facebook.app_key',      :env_var => 'FACEBOOK_APP_KEY',       :required => true
Settings.define 'omniauth.facebook.app_secret',   :env_var => 'FACEBOOK_APP_SECRET',    :required => true
Settings.define 'omniauth.vkontakte.app_key',     :env_var => 'VKONTAKTE_APP_KEY',      :required => true
Settings.define 'omniauth.vkontakte.app_secret',  :env_var => 'VKONTAKTE_APP_SECRET',   :required => true
Settings.resolve!
