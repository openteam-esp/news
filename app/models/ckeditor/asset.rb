require 'mime/types'

class Ckeditor::Asset < ActiveRecord::Base
  attr_accessible :data, :assetable_type, :assetable_id, :assetable

  set_table_name 'ckeditor_assets'
end
