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
#  id                :integer         not null, primary key
#  delete_at         :datetime
#  locked_at         :datetime
#  since             :datetime
#  deleted_by_id     :integer
#  initiator_id      :integer
#  legacy_id         :integer
#  locked_by_id      :integer
#  author            :string(255)
#  slug              :string(255)
#  state             :string(255)
#  vfs_path          :string(255)
#  image_url         :string(255)
#  annotation        :text
#  body              :text
#  title             :text
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  source            :string(255)
#  source_link       :string(255)
#  image_description :string(255)
#  type              :string(255)
#

