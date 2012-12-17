# encoding: utf-8

Fabricator(:news_entry) do
  title       'Заголовок новости'
  annotation  'Аннотация новости'
  body        'Текст новости'
  initiator
  current_user {|e| e.initiator}
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

