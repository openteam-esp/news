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
    pb = ProgressBar.new((2015..Date.today.year).count * 12)
    (2015..Date.today.year).each do |year|
      (10..12).each do |month|
        pb.increment!
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

  #protected

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
      if new_entry?(news_title)
        news_annotation = entry.children.select{|c| c.is_a? Nokogiri::XML::Text}.map(&:text).join("\n")
        news = NewsEntry.new(:title => news_title, :annotation => news_annotation)

        parsed_entry = parse_entry(news_url, news.vfs_path)
        news.body          = parsed_entry[:body]
        news.since         = parsed_entry[:time]

        unless parsed_entry[:source].empty?
          news.source      = parsed_entry[:source][:title]
          news.source_link = parsed_entry[:source][:link] if parsed_entry[:source][:link]
        end

        gallery            = parsed_entry[:gallery]

        news.set_current_user(user)
        news.channels << channel
        news.state = "published"
        news.save

        resolve_tasks(news)
        fetch_gallery_images(gallery, news)  if gallery.any?
      end
    end
  end

  def parse_entry(news_url, vfs_path)
    page = Nokogiri::HTML(open(news_url)).css("#center-side-full")                        #страница
    time = Time.zone.parse page.css(".date .hidden").text                                 #время публикации
    body = page.css(".content")                                                           #контент страницы
    text_remover(body.css("p")[0]) if body.css("p")[0]                                    #чистим контент первого p от лишних span


    gallery = body.css(".colorbox").map(&:remove)                                         #фотографии с .colorbox вырезаем и отправляем в галерею

    update_files_src body, vfs_path                                                       #перекладываем файлы на сторадж и апдейтим ссылки на них
    update_inner_images_src body, vfs_path                                                #перекладываем оставшиеся после резни изображения на сторадж и обновляем им ссылки
    update_links body

    source = find_source(body) || {}
    body.children.select{|n| n.text.squish.match(/^Источник.*:/)}.map(&:remove)           #чистим тело новости от нод источников

    body.children.each do |n|                                                             #чистим тело от пустых текстовых нод
      next if n.name == "iframe"
      text_remover n
      n.remove if n.text.squish.blank? && n.children.reject{ |c| c.name == 'br' }.empty?
    end
    puts  body.children

    return  { body: body.children.to_html.squish.gsub('<p>&nbsp;</p>', ''), time: time,  gallery: gallery, source: source }
  end

  def update_files_src(node, vfs_path)
    node.css("a").select{|a| a["href"] && a["href"].match(/^\/export\/sites/)}.each do |link|
      from = url_begin + link["href"]
      to = vfs_path
      storage_url = upload_file(from, to)
      link["href"] = storage_url
    end
  end

  def update_links(node)
    node.css("a").select{|a| a["href"] && a["href"].match(/^\/\S*/)}.each do |a|
      new_url = "http://old.tusur.ru" + a["href"]
      a["href"] = new_url
    end
  end

  def update_inner_images_src(node, vfs_path)
    node.css("img").each do |img|
      from = img["src"].match(/^\/\S*/) ? url_begin + img["src"] : img["src"]
      to = vfs_path
      storage_url = upload_file(from, to)
      img["src"] = storage_url
    end
  end

  def find_source(node)
    query = node.children.select{|n| n.text.match(/Источник.*:/)}
    if query.any?
      puts "query any"
      source = query.first                                                               #нода источника
      if source.at_css("a")
        source = source.at_css("a")
        link = source["href"]
        link = url_checker(link)
        result = { link: source["href"], title: source.text.squish }          #имя и адрес источника
        puts "link is #{result[:link]}, title is #{result[:title]}"
      else
        result = { title: source.text.squish.gsub(/Источник.*:/, "" )}
        puts result[:title]
        if result[:title] =~ /\A#{URI::regexp}\z/
          result[:link] = result[:title]
        else
          result[:link] = nil
        end
      end
      puts "success"
      return result
    end
    return
  end

  def text_remover(node)
    node.children.each do |child|
      text_remover(child) if child.children.any?
      child.remove if child.is_a?(Nokogiri::XML::Text) && child.text.squish.blank?
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
      href = href.gsub(/_\d*.\D*$/, '')
      puts href + " is href"
      storage_url = upload_file(href, news.vfs_path)
      puts storage_url + " is storage url"
      puts "**" * 30
      news.images.create(:url => storage_url)
    end
  end

  def new_entry?(title)
    channel.entries.where(:title => title.gilensize(:html => false, :raw_output => true).gsub(%r{</?.+?>}, '')).empty?
  end

  def upload_file(from, to)
    filename = from.split('/').last.gsub(/(\.\w+)_\d+\.\w+\z/, '\1').downcase
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

  def url_begin
    scheme + "://" + host
  end

  def url_checker(url)
    url.match(/^\/\S*/) ? url_begin + url : url
  end

end
