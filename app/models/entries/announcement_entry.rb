# encoding: utf-8
class AnnouncementEntry < Entry
  attr_accessible :actuality_expired_at

  def is_announce?
    true
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
#  source_link          :text
#  type                 :string(255)
#  actuality_expired_at :datetime
#  youtube_code         :string(255)
#  source_target        :string(255)
#

