SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :inbox, t('inbox'), entries_path(:folder => 'inbox')
    primary.item :published, t('published'), entries_path(:folder => 'published')
    primary.item :correcting, t('correcting'), entries_path(:folder => 'correcting')
    primary.item :draft, t('draft'), entries_path(:folder => 'draft')
    primary.item :trash, t('trash'), entries_path(:folder => 'trash')
  end
end
