class Permission < ActiveRecord::Base
  attr_accessible :role, :context
  sso_auth_permission :roles => [:administrator, :manager, :publisher, :corrector, :initiator]
end

# == Schema Information
#
# Table name: permissions
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  context_id   :integer
#  context_type :string(255)
#  role         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

