HoptoadNotifier.configure do |config|
  Settings['hoptoad'].each_pair do | key, value |
    config.send("#{key}=", value)
  end
end if defined?(HoptoadNotifier) && Settings['hoptoad']
