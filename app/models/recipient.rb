class Recipient < ActiveRecord::Base
  belongs_to :channel

  validates_presence_of :email
  validates_uniqueness_of :email

  scope :active, where(:active => true)

  default_scope order(:email)

end


# == Schema Information
#
# Table name: recipients
#
#  id          :integer         not null, primary key
#  email       :string(255)
#  description :text
#  active      :boolean
#  channel_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  old_id      :integer
#

