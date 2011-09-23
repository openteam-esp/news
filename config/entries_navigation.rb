SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[draft processing deleted].each do | state |
      primary.item "sidebar_entry_#{state}", t("sidebar.entries.#{state}"), scoped_entries_path(state), :counter => Entry.folder(state).count,
                   :highlights_on => lambda { params[:state] == state && params[:controller] == 'entries' }
    end

  end
end

