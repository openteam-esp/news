source :rubygems

group :assets do
  gem 'jquery-rails'
  gem 'therubyracer'                                                        unless RUBY_PLATFORM =~ /freebsd/
  gem 'uglifier'
  gem 'compass-rails'
end

group :default do
  gem 'attribute_normalizer'
  gem 'compass-rails'
  gem 'dynamic_form'
  gem 'el_vfs_client'
  gem 'esp-auth'
  gem 'esp-ckeditor'
  gem 'esp-commons'
  gem 'esp-gems'
  gem 'fancy-buttons'
  gem 'forgery',                                    :require => false
  gem 'friendly_id'
  gem 'gilenson'
  gem 'has_scope'
  gem 'nested_form'
  gem 'sanitize'
  gem 'sass-rails'
  gem 'simple-navigation'
  gem 'state_machine'
end

group :development do
  gem 'rails-erd'
  gem 'sunspot_solr',                             :require => false
end

group :test do
  gem 'fabrication'
  gem 'guard-rspec',                              :require => false
  gem 'guard-spork',                              :require => false
  gem 'sunspot_matchers',                         :require => false
  gem 'libnotify',                                :require => false
  gem 'rb-inotify',                               :require => false
  gem 'rspec-rails',                              :require => false
  gem 'shoulda-matchers',                         :require => false
  gem 'spork',                  '>= 1.0.0.rc2',   :require => false
  gem 'sqlite3',                                  :require => false
end

