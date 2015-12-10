require 'openteam/capistrano/recipes'
require 'whenever/capistrano'
require 'sidekiq/capistrano'

set :default_stage, 'ato'

set :shared_children, fetch(:shared_children) + %w[config/sunspot.yml]
