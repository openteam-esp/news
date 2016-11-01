# encoding: utf-8

Fabricator(:event) do
  kind "send_to_corrector"
  text "опублекуе, а ?"
end

# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  entry_id         :integer
#  task_id          :integer
#  user_id          :integer
#  event            :string(255)
#  serialized_entry :text
#  text             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

