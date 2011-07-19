if Settings['mongo.url']
  settings = URI.parse(Settings['mongo.url'])
  database_name = settings.path.gsub(/^\//, '')

  Mongoid.configure do |config|
    config.master = Mongo::Connection.new(settings.host, settings.port).db(database_name)
    config.master.authenticate(settings.user, settings.password) if settings.user
  end
end

Mongoid.configure do |config|
  config.use_utc = false
  config.use_activesupport_time_zone = true
end

