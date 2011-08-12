class Asset < ActiveRecord::Base
   has_attached_file :image
   has_attached_file :attachment
end
