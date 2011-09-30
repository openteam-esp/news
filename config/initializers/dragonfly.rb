require 'dragonfly'


assets_app = Dragonfly[:assets]
assets_app.configure_with(:rails)
assets_app.configure_with(:imagemagick)
assets_app.define_macro(ActiveRecord::Base, :asset_accessor)

if Settings[:s3]
  require 'fog'
  assets_app.datastore = Dragonfly::DataStorage::S3DataStore.new
  Dragonfly::DataStorage::S3DataStore::REGIONS[:openteam] = 's3.openteam.ru'
  assets_app.datastore.configure do |datastore|
    datastore.region = :openteam
    datastore.access_key_id = Settings['s3.access_key_id']
    datastore.secret_access_key = Settings['s3.secret_access_key']
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
