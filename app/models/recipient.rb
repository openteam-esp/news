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
#  active      :boolean
#  channel_id  :integer
#  created_at  :datetime         not null
#  description :text
#  email       :string(255)
#  id          :integer          not null, primary key
#  updated_at  :datetime         not null
#

