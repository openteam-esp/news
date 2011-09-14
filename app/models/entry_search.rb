class EntrySearch < Search
  column :content, :text
  column :since,   :date
  column :until,   :date
  column :keywords, :text
end


# == Schema Information
#
# Table name: searches
#
#  content :text
#  since   :date
#  until   :date
#

