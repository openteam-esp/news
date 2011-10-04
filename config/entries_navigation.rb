SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[draft processing deleted].each do | folder |
      primary.item "sidebar_entry_#{folder}", t("sidebar.entries.#{folder}"), scoped_entries_path(folder), :counter => Entry.folder(folder).count,
                   :highlights_on => lambda { params[:folder] == folder && params[:controller] == 'entries' }
    end

  end
end

