require "nokogiri"
require "progress_bar"
require "open-uri"
require "curl"

class Parser
  attr_accessor :url, :user, :channel, :news_selector

  def initialize(url, channel_id, news_selector = ".b-newsone")
    @url ||= url
    @user ||= User.find_by_email "mail@openteam.ru"
    @channel ||= Channel.find(channel_id)
    @news_selector ||= news_selector
  end


  def parse
    pb = ProgressBar.new(page_quantity)
    (1..@page_quantity).each do |page_number|
      paginated_url = "#{url}/page/#{page_number}"
      fetch_entries(paginated_url)
      pb.increment!
    end
  end

  private
  def fetch_entries(paginated_url)
    entries = Nokogiri::HTML(open(paginated_url)).css(news_selector)
    entries.each do |entry|
      news_title = entry.css("h2").text.squish
      news_date = DateTime.parse entry.css(".b-entry-date").text.squish
      if new_entry?(news_title, news_date)
        news_url = entry.css("h2 a").attr("href")
        news_annotation = entry.css("p").text.squish
        news_body = fetch_news_body(news_url)
        news = NewsEntry.new(:since => news_date, :title => news_title, :annotation => news_annotation, :body => news_body)
        news.since = news_date
        news.title = news_title
        news.annotation = news_annotation
        news.body = news_body
        news.set_current_user(user)
        news.channels << channel
        news.state = "published"
        news.save

        resolve_tasks(news)
        fetch_gallery_images(news_url, news)  if Nokogiri::HTML(open(news_url)).css(".gallery")
      end
    end
  end

  def fetch_news_body(news_url)
    body = Nokogiri::HTML(open(news_url)).css(".b-blog-item")
    body.css("style").remove
    body.css("script").remove
    body.css("h2").remove
    body.css(".gallery").remove
    body.css(".b-blogcomment").remove
    body.css(".b-blogcomment-count").remove
    body.css(".b-blog-date").remove
    body.css(".yashare-auto-init").first.try(:parent).try(:remove)
    body.children.to_html.squish.gsub('<p>&nbsp;</p>', '')
  end

  def fetch_gallery_images(news_url, news)
    gallery =  Nokogiri::HTML(open(news_url)).css(".gallery-item img")
    gallery.each do |node|
      storage_url = upload_file(node.attr("src").sub(/-\d{2,}x\d{2,}/,''), news.vfs_path)
      news.images.create(:url => storage_url)
    end
  end

  def new_entry?(title, news_date)
    channel.entries.where(:title => title.gilensize(:html => false, :raw_output => true).gsub(%r{</?.+?>}, ''), :since => news_date).empty?
  end

  def upload_file(from, to)
    filename = from.split('/').last.gsub(/(\.\w+)_\d+\.\w+\z/, '\1').downcase

    tmpfile = Tempfile.new(filename)
    tmpfile.binmode

    c = Curl::Easy.new(from) do |curl|
      curl.on_body { |data| tmpfile.write(data) }
      curl.on_failure { |easy| puts "Failure link #{from}" }
    end
    c.perform

    c = Curl::Easy.new("#{Settings['storage.url']}/api/el_finder/v2#{to}?cmd=upload&target=r17306_Lw") do |curl|
      curl.headers['User-Agent'] = 'curl'
      curl.headers['Accept'] = 'application/json'
      curl.headers['CLIENT_IP'] = '127.0.0.1'
      curl.headers['X_FORWARDED_FOR'] = ''
      curl.headers['REMOTE_ADDR'] = ''
      curl.multipart_form_post = true
      curl.on_failure { |easy| puts '===> Storage is not available! <===' }
    end
    c.http_post(Curl::PostField.file('upload[]', tmpfile.path, filename))
    tmpfile.close
    tmpfile.unlink

    response = JSON.parse(c.body_str)
    case response.keys.first
    when 'added'
      response = response['added'].first['url']
    when 'error'
      response = URI.extract(response['error'], ['http', 'https']).first
    end

    response
  end

  def resolve_tasks(news)
    news.tasks.each do |entry_task|
      entry_task.update_attribute :initiator, user
      entry_task.update_attribute :executor, user
      entry_task.update_attribute :state, 'completed'
    end
  end

  def page_quantity
    pagination = Nokogiri::HTML(open(url)).css(".b-paginator ul")
    @page_quantity ||= pagination.children[pagination.count-3].text.to_i
  end
end
