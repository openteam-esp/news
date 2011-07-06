require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter,    Settings['omniauth.twitter.app_key'],   Settings['omniauth.twitter.app_secret']
  provider :facebook,   Settings['omniauth.facebook.app_key'],  Settings['omniauth.facebook.app_secret']
  provider :vkontakte,  Settings['omniauth.vkontakte.app_key'], Settings['omniauth.vkontakte.app_secret']
  use OmniAuth::Strategies::OpenID, OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
end
