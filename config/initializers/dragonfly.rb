require 'dragonfly'


assets_app = Dragonfly[:assets]
assets_app.configure_with(:rails)
assets_app.configure_with(:imagemagick)
assets_app.define_macro(ActiveRecord::Base, :asset_accessor)

if Settings[:s3]
  require 'fog'
  assets_app.datastore = Dragonfly::DataStorage::S3DataStore.new
  assets_app.datastore.configure do |datastore|
    Settings[:s3].each do | key, value |
      datastore.send("#{key}=", value)
    end
  end

  class Fog::Storage::AWS::Real
    def initialize_with_openteam(options={})
      initialize_without_openteam(options.merge(:scheme => :http, :port => 80, :host => 's3.openteam.ru'))
    end
    alias_method_chain :initialize, :openteam
  end

  class Fog::Connection
    def request_with_openteam(params, &block)
      request_without_openteam(params.merge(:path => "/news-demo/#{params[:path]}"), &block)
    end
    alias_method_chain :request, :openteam
  end

else
  assets_app.datastore.configure do |datastore|
    datastore.root_path = "#{Rails.root}/assets/#{Rails.env}"
    datastore.store_meta = false
  end
end

require 'dragonfly/image_magick/utils'
module Dragonfly::ImageMagick::Utils

  def raw_identify(temp_object, args='')
    @cache ||= {}
    @cache["#{temp_object}#{args}"] ||= run "#{identify_command} #{args} \"#{temp_object.path}\" 2>/dev/null"
  end

end
