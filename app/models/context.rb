class Context < ActiveRecord::Base

  default_scope order('weight')

  attr_accessible :id, :title, :ancestry, :weight, :parent

  has_many :subcontexts, :class_name => 'Channel'
  has_many :channels
  has_many :permissions, :as => :context

  scope :with_manager_permissions_for, ->(user) {
    context_ids = user.permissions.for_role(:manager).for_context_type('Context').pluck('distinct context_id')
    where(:id => Context.where(:id => context_ids).flat_map(&:subtree_ids))
  }

  scope :with_channels, joins(:channels).uniq

  alias_attribute :to_s, :title

  has_ancestry

end
# == Schema Information
#
# Table name: contexts
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  ancestry   :string(255)
#  weight     :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

