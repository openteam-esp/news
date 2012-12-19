# encoding: utf-8

Fabricator(:channel) do
  title       'Название канала'
  parent      nil
end

# == Schema Information
#
# Table name: channels
#
#  ancestry    :string(255)
#  context_id  :integer
#  created_at  :datetime         not null
#  deleted_at  :datetime
#  description :text
#  entry_type  :string(255)
#  id          :integer          not null, primary key
#  title       :string(255)
#  title_path  :text
#  updated_at  :datetime         not null
#  weight      :text
#

