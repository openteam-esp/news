# encoding: utf-8

Fabricator(:event) do
  kind "send_to_corrector"
  text "опублекуе, а ?"
end

# == Schema Information
#
# Table name: events
#
#  created_at       :datetime         not null
#  entry_id         :integer
#  event            :string(255)
#  id               :integer          not null, primary key
#  serialized_entry :text
#  task_id          :integer
#  text             :text
#  updated_at       :datetime         not null
#  user_id          :integer
#

