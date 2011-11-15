class Video < Asset
end








# == Schema Information
#
# Table name: assets
#
#  id              :integer         not null, primary key
#  type            :string(255)
#  entry_id        :integer
#  file_name       :string(255)
#  file_mime_type  :string(255)
#  file_size       :integer
#  file_updated_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  file_uid        :string(255)
#  file_width      :integer
#  file_height     :integer
#  legacy_id       :integer
#

