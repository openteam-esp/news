source 'http://rubygems.org'

group :assets do
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'execjs'
  gem 'fancy-buttons'
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'uglifier'
end

group :default do
  gem 'ancestry'
  gem 'attribute_normalizer'
  gem 'audited-activerecord'
  gem 'decent_exposure'
  gem 'default_value_for'
  gem 'devise'
  gem 'devise-russian'
  gem 'dynamic_form'
  gem 'el_vfs_client'
  gem 'esp-ckeditor'
  gem 'esp-commons'
  gem 'esp-views'
  gem 'forgery',                                    :require => false
  gem 'formtastic',       '< 2.2.0'
  gem 'friendly_id'
  gem 'gilenson'
  gem 'has_enum'
  gem 'has_scope'
  gem 'has_searcher',     '< 0.0.90'
  gem 'inherited_resources'
  gem 'kaminari'
  gem 'nested_form'
  gem 'openteam-commons'
  gem 'progress_bar'
  gem 'russian'
  gem 'sanitize'
  gem 'simple-navigation'
  gem 'sso-auth'
  gem 'state_machine'
  gem 'sunspot_rails',    '>= 2.0.0.pre.120417'
  gem 'timecop',          :require => false
end

group :development do
  gem 'annotate'
  gem 'brakeman'
  gem 'capistrano-ext'
  gem 'debugger'
  gem 'hirb',                                     :require => false
  gem 'rails-erd'
  gem 'rvm-capistrano'
  gem 'sunspot_solr',     '>= 2.0.0.pre.120417',  :require => false
end

group :linux do
   gem 'libv8'                                     unless RUBY_PLATFORM =~ /freebsd/
   gem 'therubyracer'                              unless RUBY_PLATFORM =~ /freebsd/
end

group :production do
  gem 'pg'
end

group :test do
  gem 'fabrication',      '< 2.0.0'
  gem 'rspec-rails',                              :require => false
  gem 'shoulda-matchers',                         :require => false
  gem 'sqlite3',                                  :require => false
  gem 'sunspot_matchers',                         :require => false
  gem 'timecop'
end
