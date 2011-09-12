require 'spork'

Spork.prefork do
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

    config.before(:each) do
      require 'fabrication'
    end

    config.after(:each) do
      ActiveRecord::Base.descendants.each do | klass |
        klass.delete_all unless klass.abstract_class?
      end
    end
  end
end
