require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_record/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module News
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(
                                #{config.root}/app/navigation_renderers
                                #{config.root}/app/models/asset
                                #{config.root}/app/models/issues
                                #{config.root}/lib
                               )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Novosibirsk'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults]  = %w(jquery.min jquery.ujs)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # See everything in the log (default is :info)
    config.log_level = :info

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.generators do | generators |
      generators.test_framework       :rspec, :fixture => true
      generators.fixture_replacement  :fabrication
    end

    config.middleware.insert_after 'Warden::Manager', 'Esp::Middleware::SetCurrentUser'
    config.middleware.insert_after 'Esp::Middleware::SetCurrentUser', 'Esp::Middleware::AuthorizeAssets'
    config.middleware.insert_after 'Esp::Middleware::AuthorizeAssets', 'Dragonfly::Middleware', :assets
    config.middleware.insert_before 'Dragonfly::Middleware', 'Rack::Cache', {
      :verbose     => true,
      :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"),
      :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
    }
  end
end

