require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  Settings['omniauth'].each_pair do | name, app |
    provider name, app['key'], app['secret']
  end
  use OmniAuth::Strategies::OpenID, OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end
