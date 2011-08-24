class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  has_enum :kind, %w[corrector publisher]
  validates_uniqueness_of :kind


  enums[:kind].each do |role|
    define_singleton_method role do
      find_by_kind(role)
    end
  end

  # TODO: remove me
  def self.correctors
    find_by_kind('corrector').users if find_by_kind('corrector').present?
  end

  def self.publishers
    find_by_kind('publisher').users if find_by_kind('publisher').present?
  end

  def to_s
    human_kind
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  kind       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

