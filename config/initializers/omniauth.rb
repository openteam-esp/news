Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Settings['omniauth.twitter.consumer_key'], Settings['omniauth.twitter.consumer_secret']
end
