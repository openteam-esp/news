class EntrySearch < Search
  column :keywords,        :text
  column :since_lt,        :date
  column :since_gt,        :date
  column :until_lt,        :date
  column :until_gt,        :date
  column :channel_ids,     :string
  column :order_by,        :string

  has_enum :order_by

  default_value_for :order_by, 'since desc'
  default_value_for :channel_ids, do Channel.all.map(&:id) end

  def state
    'published'
  end

  def channel_ids
    self[:channel_ids].map(&:to_i) if self[:channel_ids]
  end
end


# == Schema Information
#
# Table name: searches
#
#  content :text
#  since   :date
#  until   :date
#

