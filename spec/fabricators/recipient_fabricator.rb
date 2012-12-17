Fabricator(:recipient) do
  email "MyString"
end

# == Schema Information
#
# Table name: recipients
#
#  active      :boolean
#  channel_id  :integer
#  created_at  :datetime         not null
#  description :text
#  email       :string(255)
#  id          :integer          not null, primary key
#  updated_at  :datetime         not null
#

