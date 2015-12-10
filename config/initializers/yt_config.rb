Yt.configure do |config|
  config.log_level = :debug if Rails.env.development?
  config.api_key = Settings['youtube.api_key']
end
