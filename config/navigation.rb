SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :inbox, t('inbox'), folder_entries_path(Folder.where(:title => 'inbox').first)
    primary.item :published, t('published'), folder_entries_path(Folder.where(:title => 'published').first)
    primary.item :correcting, t('correcting'), folder_entries_path(Folder.where(:title => 'correcting').first)
    primary.item :draft, t('draft'), folder_entries_path(Folder.where(:title => 'draft').first)
    primary.item :trash, t('trash'), folder_entries_path(Folder.where(:title => 'trash').first)
  end
end
