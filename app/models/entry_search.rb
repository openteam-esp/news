class EntrySearch < Search
  column :keywords,       :text
  column :since_lt,       :date
  column :since_gt,       :date
  column :channel_ids,    :string
  column :order_by,       :string
  column :per_page,       :integer
  column :state,          :string
  column :updated_at_gt,  :date

  has_enum :order_by

  default_value_for :order_by, 'since desc'
  default_value_for :channel_ids do Channel.all.map(&:id) end

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
#  keywords      :text
#  since_lt      :date
#  since_gt      :date
#  channel_ids   :string
#  channel_slugs :string
#  order_by      :string
#  per_page      :integer
#  state         :string
#  updated_at_gt :date
#

