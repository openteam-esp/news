class VideoParser < Parser
  protected

  def fetch_entries(paginated_url)
    entries = Nokogiri::HTML(open(paginated_url)).css(news_selector)
    entries.each do |entry|
      video_title = entry.css("span strong").text.squish
      video_date = Time.zone.parse entry.css(".datetime").text.squish
      if new_entry?(video_title, video_date)
        create_video_entry(video_title, video_date, entry.attr('href'))
      end
    end
  end

  def create_video_entry(title, date, body_url)
    video = Nokogiri::HTML(open(body_url)).css(".b-whiteblock")
    annotation = video.css(".b-youtubeblock iframe").attr("src").text.split("/").last
    body = video.css(".b-videoinfo p").text.squish.gsub("&nbsp;",'')
    video_news = NewsEntry.new(:since => date, :title => title, :annotation => annotation, :body => body)
    video_news.set_current_user(user)
    video_news.channels << channel
    video_news.state = "published"
    video_news.save

    resolve_tasks(video_news)
  end
end
