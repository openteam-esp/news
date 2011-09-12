class Issue < ActiveRecord::Base

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'
  default_scope order(:id)

end

# == Schema Information
#
# Table name: issues
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#

