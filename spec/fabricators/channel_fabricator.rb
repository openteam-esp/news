# encoding: utf-8

Fabricator(:channel) do
  title       'Название канала'
  parent      nil
end

# == Schema Information
#
# Table name: channels
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  ancestry     :string(255)
#  title        :string(255)
#  weight       :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  entry_type   :string(255)
#  title_path   :text
#  description  :text
#  channel_code :string(255)
#

