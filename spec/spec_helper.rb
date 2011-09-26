require 'spork'


Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require "cancan/matchers"
  require 'shoulda-matchers'
  require 'sunspot_matchers'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  require "#{Rails.root}/spec/support/deferred_garbage_collection"

  Dir[Rails.root.join("spec/support/helpers/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller
    config.include EspSpecHelper
    config.mock_with :rspec
    config.after do User.current = nil end
    config.before do
      DeferredGarbageCollection.start
    end
    config.after do
      DeferredGarbageCollection.reconsider
    end
    config.before(:all) do
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
    end
    config.before(:all) do
      Dir[Rails.root.join("spec/support/matchers/*.rb")].each {|f| require f}
      require Rails.root.join 'app/models/tasks/task'
      require 'fabrication'
    end
  end
end

