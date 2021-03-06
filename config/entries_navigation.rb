SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[draft processing deleted].each do | folder |
      primary.item "sidebar_entry_#{folder}", t("sidebar.entries.#{folder}"), manage_news_scoped_entries_path(folder), :counter => Entry.folder(folder, current_user).count('DISTINCT entries.id'),
                   :highlights_on => lambda { params[:folder] == folder && params[:controller] == 'manage/news/entries' }
    end

  end
end

