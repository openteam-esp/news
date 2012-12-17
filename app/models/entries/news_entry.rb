class NewsEntry < Entry
  # NOTE: используется для методов min_since_event_datetime и max_until_event_datetime в #EntrySearch
  def event_entry_properties
    []
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

