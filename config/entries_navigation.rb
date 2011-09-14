SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[draft processing trashed].each do | state |
      primary.item "sidebar_entry_#{state}", t("sidebar.#{state}"), "/#{state}#{entries_path}", :counter => Entry.state(state).count,
                   :highlights_on => lambda { params[:state] == state || (params[:controller] == 'entries' && @entry.try(:state) == state) }
    end

  end
end

