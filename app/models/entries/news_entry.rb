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

