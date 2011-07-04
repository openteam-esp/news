Settings.read Rails.root.join 'config', 'settings.yml'
#Settings.define 'hoptoad.api_key',        :env_var => 'HOPTOAD_API_KEY',    :required => Rails.env.production?
#Settings.define 'secret_token',           :env_var => 'SECRET_TOKEN',       :required => true
Settings.define 'mongo.url',                :env_var => 'MONGO_URL'
Settings.define 'omniauth.twitter.consumer_key',      :env_var => 'TWITTER_CONSUMER_KEY',     :required => true
Settings.define 'omniauth.twitter.consumer_secret',   :env_var => 'TWITTER_CONSUMER_SECRET',  :required => true
Settings.resolve!
