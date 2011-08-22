class Asset < ActiveRecord::Base
  belongs_to :entry

  def self.before_destroy(*args) # disable destroy_attached_files
  end

  has_attached_file :file

  before_create :set_type

  private

    def set_type
      mime_group = file_content_type.split('/')[0]
      self.type = %w[audio video image].include?(mime_group) ? mime_group.classify : 'Attachment'
    end
end



# == Schema Information
#
# Table name: assets
#
#  id                :integer         not null, primary key
#  type              :string(255)
#  entry_id          :integer
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#

