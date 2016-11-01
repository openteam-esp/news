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
#  id          :integer          not null, primary key
#  active      :boolean
#  channel_id  :integer
#  email       :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

