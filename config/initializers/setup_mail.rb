ActionMailer::Base.smtp_settings = Settings[:smtp_settings]
ActionMailer::Base.default_url_options[:host] = Settings[:host]
