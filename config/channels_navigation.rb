SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    Channel.all.each do |channel|
      primary.item :channel,
                    "#{channel.title}</a><a href='#{channel_rss_path(channel)}' class='rss_link'>#{channel.title} RSS",
                    channel_published_entries_path(channel)
    end
  end
end

