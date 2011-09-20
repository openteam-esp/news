#require 'spork'

#Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require "cancan/matchers"
  require 'shoulda-matchers'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


  RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller
    config.include Esp::SpecHelper

    config.mock_with :rspec

    config.before(:all) do
      ActiveRecord::Base.establish_connection(:adapter => :nulldb)
    end

    config.before(:each) do
      ActiveRecord::Base.connection.checkpoint!
      require Rails.root.join "app/models/tasks/task"
      require 'fabrication'
    end
  end
#end

