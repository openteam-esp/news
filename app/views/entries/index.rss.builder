xml.instruct!

xml.rss 'version' => '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    xml.title ''
    xml.link root_url
    xml.description ''

    collection.each do |news|
      xml.item do
        xml.title       news.title
        xml.description "#{image_for(news, :width => 100, :height => 100)} #{news.annotation}", :type => :html
        xml.link        entry_url(news)
        xml.pubDate     news.since.rfc822
      end
    end
  end
end

