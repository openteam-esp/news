class EntrySearch < Search
  column :annotation, :text
  column :body,       :text
  column :title,      :text
  column :since,      :date
  column :until,      :date
end
