# encoding: utf-8

class EventEntry < Entry
  has_many :event_entry_properties

  accepts_nested_attributes_for :event_entry_properties

  def as_json(options={})
    super options.merge(:methods => :event_entry_properties)
  end
end

# == Schema Information
#
# Table name: entries
#
#  actuality_expired_at :datetime
#  annotation           :text
#  author               :string(255)
#  body                 :text
#  created_at           :datetime         not null
#  delete_at            :datetime
#  deleted_by_id        :integer
#  id                   :integer          not null, primary key
#  initiator_id         :integer
#  legacy_id            :integer
#  locked_at            :datetime
#  locked_by_id         :integer
#  since                :datetime
#  slug                 :string(255)
#  source               :string(255)
#  source_link          :string(255)
#  state                :string(255)
#  title                :text
#  type                 :string(255)
#  updated_at           :datetime         not null
#  vfs_path             :string(255)
#

