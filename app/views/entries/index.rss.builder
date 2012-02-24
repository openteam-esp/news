xml.instruct!

xml.rss 'version' => '2.0' do
  xml.channel do
    xml.title "#{t('title_rss_channel')} - #{@channel.try(:title)}"
    xml.link root_url
    xml.description t('description_rss_channel')

    collection.each do |news|
      xml.item do
        xml.title       news.title
        xml.link        entry_url(news)
        xml.pubDate     news.since.rfc822

        xml.description rss_description(news), :type => :html
      end
    end
  end
end

