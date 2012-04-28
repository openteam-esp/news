require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require "cancan/matchers"
  require 'shoulda-matchers'
  require 'sunspot_matchers'
  require "esp_auth/spec_helper"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/helpers/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/support/matchers/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller
    config.include EspNewsSpecHelper
    config.include EspAuth::SpecHelper
    config.include AttributeNormalizer::RSpecMatcher

    config.mock_with :rspec

    config.use_transactional_fixtures = true

    config.before :all do
      ActiveRecord::IdentityMap.enabled = true

      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
    end

    config.before do
      stub_message_maker
    end
  end
end

