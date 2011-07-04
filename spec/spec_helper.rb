require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'database_cleaner'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|

    include Mongoid::Matchers

    config.mock_with :rspec

    config.before(:each) do
      DatabaseCleaner.strategy = :truncation
      #Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    end
  end
end

Spork.each_run do
end

