SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[last_day last_week last_month].each do | archive |
      primary.item "sidebar_archive_#{archive}", t("sidebar.archive.#{archive}"), send("#{archive}_entries_path")
    end
    primary.item "sidebar_archive_search", t("sidebar.archive.search"), public_entries_path

  end
end

