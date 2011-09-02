require 'dragonfly'

assets_app = Dragonfly[:assets]
assets_app.configure_with(:rails)
assets_app.configure_with(:imagemagick)
assets_app.define_macro(ActiveRecord::Base, :asset_accessor)


require 'dragonfly/image_magick/utils'
module Dragonfly::ImageMagick::Utils

  def raw_identify(temp_object, args='')
    @cache ||= {}
    @cache["#{temp_object}#{args}"] ||= run "#{identify_command} #{args} \"#{temp_object.path}\" 2>/dev/null"
  end

end
