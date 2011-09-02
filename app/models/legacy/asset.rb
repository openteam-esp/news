class Legacy::Asset < ActiveRecord::Base
  set_inheritance_column :_type

  establish_connection "legacy_#{Rails.env}"
  set_table_name "attachments"

  default_scope order(:id)

  belongs_to :entry, :class_name => 'Legacy::Entry', :foreign_key => 'event_id'
  has_attached_file :file

end


# == Schema Information
#
# Table name: attachments
#
#  id                :integer         not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  event_id          :integer
#  description       :text
#  type              :string
#

