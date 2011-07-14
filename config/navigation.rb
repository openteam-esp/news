SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :inbox, t('inbox'), folder_entries_path(Folder.where(:title => 'inbox').first), :highlights_on => lambda {@folder.inbox?}
    primary.item :published, t('published'), folder_entries_path(Folder.where(:title => 'published').first), :highlights_on => lambda {@folder.published?}
    primary.item :correcting, t('correcting'), folder_entries_path(Folder.where(:title => 'correcting').first), :highlights_on => lambda {@folder.correcting?}
    primary.item :draft, t('draft'), folder_entries_path(Folder.where(:title => 'draft').first), :highlights_on => lambda {@folder.draft?}
    primary.item :trash, t('trash'), folder_entries_path(Folder.where(:title => 'trash').first), :highlights_on => lambda {@folder.trash?}
  end
end
