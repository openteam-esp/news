Settings.read Rails.root.join 'config', 'settings.yml'
#Settings.define 'secret_token',              :env_var => 'SECRET_TOKEN',       :required => true

Settings.define 's3.access_key_id',           :env_var => 'S3_ACCESS_KEY_ID'
Settings.define 's3.secret_access_key',       :env_var => 'S3_SECRET_ACCESS_KEY'
Settings.define 's3.bucket_name',             :env_var => 'S3_BUCKET_NAME'
Settings.define 's3.host',                    :env_var => 'S3_HOST'

Settings.define 'hoptoad.api_key',            :env_var => 'HOPTOAD_API_KEY'
Settings.define 'hoptoad.host',               :env_var => 'HOPTOAD_HOST'

Settings.define 'omniauth.twitter.key',       :env_var => 'TWITTER_KEY'
Settings.define 'omniauth.twitter.secret',    :env_var => 'TWITTER_SECRET'
Settings.define 'omniauth.facebook.key',      :env_var => 'FACEBOOK_KEY'
Settings.define 'omniauth.facebook.secret',   :env_var => 'FACEBOOK_SECRET'
Settings.define 'omniauth.vkontakte.key',     :env_var => 'VKONTAKTE_KEY'
Settings.define 'omniauth.vkontakte.secret',  :env_var => 'VKONTAKTE_SECRET'

Settings.resolve!
