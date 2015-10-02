require "nokogiri"
require "progress_bar"
require "open-uri"
require "uri"
require "curl"

class TusurNewsParser
  attr_accessor :url, :user, :channel, :news_selector, :host, :scheme

  def initialize(url, channel_id, news_selector = "#content #center-side-full .subnode")
    @url  = url
    @host = URI.parse(@url).host
    @scheme = URI.parse(@url).scheme
    @user ||= User.find_by_email "mail@openteam.ru"
    @channel ||= Channel.find(channel_id)
    @news_selector ||= news_selector
  end


  def parse
    (2007..Date.today.year).each do |year|
      (1..12).each do |month|
        month = month.to_s.rjust(2, '0')
        puts "importing #{year}.#{month}"
        next if Date.today < Date.parse("01.#{month}.#{year}")
        (0..page_quantity(url_builder(url, year, month))).each do |page_number|
          paginated_url = "#{@url}#{year}/#{month}&page=#{page_number}"
          fetch_entries(paginated_url)
        end
      end
    end
  end

  protected

  def fetch_entries(paginated_url)
    entries = Nokogiri::HTML(open(paginated_url)).css(news_selector)
    entries.each do |entry|
      begin
        news_url = scheme + "://" + host + entry.at_css(".subnode-name a")['href']
        puts news_url
      rescue
        next
      end
      news_title = entry.css(".subnode-name").text.squish
      news_date = Time.zone.parse entry.css(".subnode-date").text
      if new_entry?(news_title, news_date)
        news_annotation = entry.text.squish
        news = NewsEntry.new(:since => news_date, :title => news_title, :annotation => news_annotation)
        news_body = fetch_news_body(news_url)
        news.body = news_body[:body]
        news.set_current_user(user)
        news.channels << channel
        news.state = "published"
        news.save
        resolve_tasks(news)
        fetch_gallery_images(news_body[:gallery], news)  if news_body[:gallery].any?
      end
    end
  end

  def fetch_news_body(news_url)
    body = Nokogiri::HTML(open(news_url)).css("#center-side-full .content")
    text_remover(body.css("p")[0]) if body.css("p")[0]
    gallery = body.css(".colorbox").map(&:remove)
    body.children.each{ |n| n.remove if n.text.blank? }
    return { body: body.children.to_html.squish.gsub('<p>&nbsp;</p>', ''), gallery: gallery }
  end

  def text_remover(node)
    node.children.each do |child|
      text_remover(child) if child.children.any?
      child.remove if child.is_a? Nokogiri::XML::Text
    end
  end

  def fetch_gallery_images(gallery, news)
    gallery.each do |node|
      href = scheme + "://" + host
      if node.css("img").any?
        href += node.at_css("img")["src"]
      elsif node['href'].nil?
        next
      end
      storage_url = upload_file(node.attr("href"), news.vfs_path)
      news.images.create(:url => storage_url)
    end
  end

  def new_entry?(title, news_date)
    true
    #channel.entries.where(:title => title.gilensize(:html => false, :raw_output => true).gsub(%r{</?.+?>}, ''), :since => news_date).empty?
  end

  def upload_file(from, to)
    filename = from.split('/').last.gsub(/(\.\w+)_\d+\.\w+\z/, '\1').downcase

    return "http://storage.esp.tomsk.gov.ru/files/78458/70-85/zhvachkin.jpg" if filename == "zhvachkin.jpg"
    return "http://storage.esp.tomsk.gov.ru/files/78459/70-74/golovatov-1.jpg" if filename == "golovatov-1.jpg"

    tmpfile = Tempfile.new(filename)
    tmpfile.binmode

    begin
      rest = RestClient::Request.execute(method: :get, url: from, timeout: -1, :open_timeout => -1)
      if rest.code == 200
        tmpfile.write(rest.to_str)
      else
        puts "Failure link #{from}"
        return false
      end

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
    rescue
      false
    end
  end

  def resolve_tasks(news)
    news.tasks.each do |entry_task|
      entry_task.update_attribute :initiator, user
      entry_task.update_attribute :executor, user
      entry_task.update_attribute :state, 'completed'
    end
  end

  def page_quantity(url)
    pagination = Nokogiri::HTML(open(url)).css("a").select{|n| n["href"].match(/page=\d/)}
    pagination.any? ? pagination.last['href'].split(/page=/).last.to_i : 0
  end

  def url_builder(base, year, month = 0, page = 0)
    "#{base}#{year}/#{month}/&page=#{page}"
  end

end
