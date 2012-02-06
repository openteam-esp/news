source :rubygems

gem 'attribute_normalizer'
gem 'cancan'
gem 'compass',                  '~> 0.12.alpha.4'
gem 'default_value_for'
gem 'delayed_job'
gem 'devise-russian'
gem 'dynamic_form'
gem 'el_vfs_client'
gem 'esp-ckeditor'
gem 'esp-commons'
gem 'esp-auth'
gem 'fancy-buttons'
gem 'forgery',                                    :require => false
gem 'formtastic'
gem 'formtastic_date_as_string'
gem 'friendly_id',              '>= 4.0.0.rc2'
gem 'gilenson'
gem 'has_enum'
gem 'has_scope'
gem 'has_searcher'
gem 'inherited_resources'
gem 'jquery-rails'
gem 'kaminari'
gem 'rails'
gem 'russian'
gem 'ryba',                                       :require => false
gem 'sanitize'
gem 'sass-rails'
gem 'simple-navigation'
gem 'sso_client'
gem 'state_machine'
gem 'sunspot_matchers',                           :require => false
gem 'sunspot_rails'

group :assets do
  gem 'therubyracer'                                                        unless RUBY_PLATFORM =~ /freebsd/
  gem 'uglifier'
end

group :development do
  gem 'annotate',                                 :require => false
  gem 'guard-rspec',                              :require => false
  gem 'guard-spork',                              :require => false
  gem 'hirb',                                     :require => false
  gem 'libnotify',                                :require => false
  gem 'rb-inotify',                               :require => false
  gem 'rdiscount',                                :require => false
  gem 'rails-erd'
  gem 'secondbase'
  gem 'spork',                  '>= 0.9.0.rc9',   :require => false
  gem 'sunspot_solr',                             :require => false
  gem 'unicorn',                                  :require => false
  gem 'ya2yaml',                                  :require => false
end

group :production do
  gem 'hoptoad_notifier'
  gem 'pg',                                       :require => false
  gem 'unicorn',                                  :require => false         unless ENV['SHARED_DATABASE_URL']
end

group :test do
  gem 'fabrication'
  gem 'rspec-rails',            '~> 2.6.0',       :require => false
  gem 'secondbase'
  gem 'shoulda-matchers',                         :require => false
  gem 'sqlite3',                                  :require => false
end

