Fabricator(:recipient) do
  email "MyString"
end

# == Schema Information
#
# Table name: recipients
#
#  id          :integer          not null, primary key
#  active      :boolean
#  channel_id  :integer
#  email       :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

