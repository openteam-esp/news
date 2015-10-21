
class YoutubeEntry < Entry
  # NOTE: используется для методов min_since_event_datetime и max_until_event_datetime в #EntrySearch
  attr_accessible :youtube_code
  validates_presence_of :youtube_code

  def event_entry_properties
    []
  end
end

# == Schema Information
#
# Table name: entries
#
#  id                   :integer          not null, primary key
#  deleted_at           :datetime
#  since                :datetime
#  deleted_by_id        :integer
#  initiator_id         :integer
#  legacy_id            :integer
#  author               :string(255)
#  slug                 :string(255)
#  state                :string(255)
#  vfs_path             :string(255)
#  annotation           :text
#  body                 :text
#  title                :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  source               :text
#  source_link          :string(255)
#  type                 :string(255)
#  actuality_expired_at :datetime
#

