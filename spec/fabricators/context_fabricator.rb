# encoding: utf-8

Fabricator(:context) do
  title "Категория"
end

# == Schema Information
#
# Table name: contexts
#
#  ancestry   :string(255)
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  title      :string(255)
#  updated_at :datetime         not null
#  weight     :string(255)
#

