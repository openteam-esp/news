SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    %w[day week month].each do | archive |
      primary.item "sidebar_archive_#{archive}", t("sidebar.archive.last_#{archive}"), manage_archive_path(archive)
    end
    primary.item "sidebar_archive_search", t("sidebar.archive.search"), entries_path
  end
end

