class Asset < ActiveRecord::Base
  belongs_to :entry

  scope :type, ->(type) { type == 'assets' ? scoped : where(:type => type.classify) }

  default_scope order('created_at desc')

  asset_accessor :file do
    storage_path { "#{I18n.l entry.created_at, :format => "%Y/%m/%d"}/#{entry_id}/#{Time.now.to_i}-#{file_name}"}
  end

  def file_type
    self.file_mime_type.gsub("/", "_").gsub("-", "_").gsub(".", "_")
  end

  before_create :set_type

  def deleted?
    deleted_at
  end

  def mark_as_deleted
    update_attribute :deleted_at, Time.now
  end

  private

    def set_type
      mime_group = file_mime_type.to_s.split('/')[0]
      self.type = %w[audio video image].include?(mime_group) ? mime_group.classify : 'Attachment'
    end
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
#  description     :text
#

