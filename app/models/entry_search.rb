class EntrySearch < Search
  column :keywords,        :text
  column :since_lt,        :date
  column :since_gt,        :date
  column :until_lt,        :date
  column :until_gt,        :date
  column :channel_ids,     :integer
  column :order_by,        :string

  default_value_for :order_by, 'since desc'

  has_enum :order_by, ['since asc', 'since desc']
end


# == Schema Information
#
# Table name: searches
#
#  content :text
#  since   :date
#  until   :date
#

