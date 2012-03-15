#encoding: utf-8

xml.instruct!

xml.rss 'version' => '2.0' do
  xml.channel do
    xml.title @channel.try(:title_path).gsub('/', ' – ')
    xml.link root_url

    collection.each do |news|
      xml.item do
        xml.title       news.title
        xml.link        entry_url(news)
        xml.pubDate     news.since.rfc822

        xml.description do
          xml.cdata!  rss_description(news)
        end
      end
    end
  end
end

