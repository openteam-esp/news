class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  has_enum :kind, %w[corrector publisher]
  validates_uniqueness_of :kind

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
