source :rubygems

group :assets do
  gem 'therubyracer'                                                        unless RUBY_PLATFORM =~ /freebsd/
  gem 'uglifier'
end

group :default do
  gem 'attribute_normalizer'
  gem 'compass-rails'
  gem 'dynamic_form'
  gem 'el_vfs_client'
  gem 'esp-auth'
  gem 'esp-ckeditor'
  gem 'esp-gems'
  gem 'fancy-buttons'
  gem 'forgery',                                    :require => false
  gem 'formtastic',       '< 2.2.0'
  gem 'friendly_id'
  gem 'gilenson'
  gem 'has_scope'
  gem 'jquery-rails'
  gem 'nested_form'
  gem 'openteam-commons'
  gem 'sanitize'
  gem 'sass-rails'
  gem 'simple-navigation'
  gem 'state_machine'
  gem 'sunspot_rails',    '>= 2.0.0.pre.120417'
end

group :development do
  gem 'rails-erd'
  gem 'rvm-capistrano'
  gem 'sunspot_solr',     '>= 2.0.0.pre.120417',  :require => false
end

group :test do
  gem 'fabrication',      '< 2.0.0'
  gem 'guard-rspec',                              :require => false
  gem 'guard-spork',                              :require => false
  gem 'sunspot_matchers',                         :require => false
  gem 'libnotify',                                :require => false
  gem 'rb-inotify',                               :require => false
  gem 'rspec-rails',                              :require => false
  gem 'shoulda-matchers',                         :require => false
  gem 'spork',                  '>= 1.0.0.rc2',   :require => false
  gem 'sqlite3',                                  :require => false
  gem 'timecop'
end
