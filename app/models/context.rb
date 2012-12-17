class Context < ActiveRecord::Base
  esp_auth_context :subcontext => 'Channel'

  has_many :channels

  scope :with_manager_permissions_for, ->(user) {
    context_ids = user.permissions.for_role(:manager).for_context_type('Context').pluck('distinct context_id')
    where(:id => Context.where(:id => context_ids).flat_map(&:subtree_ids))
  }

  scope :with_channels, joins(:channels).uniq

  def polymorphic_context_value
    "#{self.class.name.underscore}_#{self.id}"
  end
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

