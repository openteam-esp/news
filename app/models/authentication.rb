class Authentication < ActiveRecord::Base
  belongs_to :user
end

# == Schema Information
#
# Table name: authentications
#
#  id       :integer         not null, primary key
#  user_id  :integer
#  provider :string(255)
#  uid      :string(255)
#

