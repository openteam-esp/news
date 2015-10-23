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
    @error_counter = {}
    @legacy_urls = []
  end


  def parse
    months = 1..12
    years = 2007..Date.today.year
    pb = ProgressBar.new(years.count * months.count)
    years.each do |year|
      months.each do |month|
        pb.increment!
        month = month.to_s.rjust(2, '0')
        puts "importing #{year}.#{month}"
        next if Date.today < Date.parse("01.#{month}.#{year}")
        (0..page_quantity(news_url_builder(url, year, month))).each do |page_number|
          paginated_url = "#{@url}#{year}/#{month}&page=#{page_number}"
          fetch_entries(paginated_url)
        end
      end
    end
    puts "Errors:"
    @error_counter.each do |key, value|
      puts key
      puts value
    end
    write_to "legacy_urls_news.yml"
  end

  def fetch_entries(paginated_url)
    entries = Nokogiri::HTML(open(paginated_url)).css(news_selector)
    entries.each do |entry|
      next if entry.at_css(".subnode-name a").nil?
      news_url = url_begin + entry.at_css(".subnode-name a")['href']
      news_title = entry.css(".subnode-name").text.squish
      node_cleaner entry, ".subnode-name", '.subnode-date'
      news_annotation = entry.text.squish
      news = NewsEntry.new(:title => news_title, :annotation => news_annotation)

      if new_entry?(news)
        parsed_entry = parse_entry(news_url, news)
        news.body          = parsed_entry[:body].present? ? parsed_entry[:body] : "-"
        news.body == "-" ? @error_counter["#{news_url}"] = "Пустое тело на урле" : 0
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
        raise news.errors.inspect if news.errors.any?
        @legacy_urls << {"'#{news_url}'" => "'#{news.slug}'"}

        resolve_tasks(news)
        fetch_gallery_images(gallery, news) if gallery.any?
      end
    end
  end

  def parse_entry(news_url, entry)
    puts news_url
    page = Nokogiri::HTML(open(news_url)).css("#center-side-full")                        #страница
    time = get_time(page)                                                                 #время публикации
    body = get_body(page, entry)                                                          #контент страницы
    recursive_node_cleaner(body.at_css("p"), "", %w(p span br text )) if body.at_css("p") #чистим контент первого p от лишних span

    gallery = body.css(".colorbox").map(&:remove)                                         #фотографии с .colorbox вырезаем и отправляем в галерею
    remove_duplicate_links(body, gallery)
    update_files_src body, entry.vfs_path                                                 #перекладываем файлы на сторадж и апдейтим ссылки на них
    update_inner_images_src body, entry.vfs_path                                          #перекладываем оставшиеся после резни изображения на сторадж и обновляем им ссылки
    update_links body

    source = find_source(body) || {}
    recursive_node_cleaner(body, /^$/, %w(br p span text))                                #чистим тело новости от пустых элементов
    return  { body: body.children.to_html.squish.gsub('<p>&nbsp;</p>', ''), time: time,  gallery: gallery, source: source }
  end


  private

  def update_files_src(node, vfs_path)
    node.css("a").select{|a| a["href"] && a["href"].match(/^\/export\/sites/)}.each do |link|
      from = url_begin + link["href"]
      to = vfs_path
      storage_url = upload_file(from, to)
      link["href"] = storage_url
    end
  end

  def remove_duplicate_links(node, gallery)
    regex = /_\d*[.]jpg$/
    duplicates = node.css("a img").select{ |i| i["src"].gsub(regex, "") == i.parent["href"] }
    duplicates.each do |image|
      a = image.parent
      image["src"] = image["src"].gsub(regex, '')
      gallery << image
      image.remove
      a.remove if a.text.squish.empty?
    end
  end

  def update_links(node)
    node.css("a").select{|a| a["href"] && a["href"].match(/^\/\S*/)}.each do |a|
      new_url = "http://old.tusur.ru" + a["href"]
      a["href"] = new_url
    end
  end

  def get_body(page, entry)
    page.css ".content"
  end

  def get_time(page)
    Time.zone.parse page.css(".date .hidden").text
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
      source = query.first                                                               #нода источника
      if source.at_css("a")
        source = source.at_css("a")
        link = source["href"]
        link = url_checker(link)
        result = { link: source["href"], title: source.text.squish }          #имя и адрес источника
      else
        result = { title: source.text.squish.gsub(/Источник.*:/, "" )}
        if result[:title] =~ /\A#{URI::regexp}\z/
          result[:link] = result[:title]
        else
          result[:link] = nil
        end
      end
      query.first.remove
      return result
    end
    return
  end

  def recursive_node_cleaner(node, regex, names)
    node.children.each do |child|
      recursive_node_cleaner(child, regex, names)
    end
    begin
      node.remove if node.children.empty? && names.include?(node.name) && node.text.squish.gsub(/[[:space:]]|\s|\\n/, '').match(regex)
    rescue
      return
    end
  end

  def node_cleaner(node, *selectors)
    selectors.each do |selector|
      node.css(selector).remove
    end
  end

  def fetch_gallery_images(gallery, news)
    images = []
    gallery.each do |node|
      if node.css("img").any?
        images << node.at_css("img")
      elsif node.name == "img"
        images << node
      elsif node['href'].nil? || node["src"].nil?
        next
      end
    end
    images.each do |image|
      href = url_begin + image["src"].gsub(/_\d*.\D*$/, '')
      description = image["alt"] || image["title"] || ""
      storage_url = upload_file(href, news.vfs_path)
      news.images.create(:url => storage_url, :description => description )
    end
  end

  def new_entry?(entry)
    channel.entries.where(:title => entry.title.gilensize(:html => false, :raw_output => true).gsub(%r{</?.+?>}, '')).empty?
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

  def write_to(filename)
    file = File.open(filename, 'a+')
    yml = YAML.load_stream file
    hash = {}
    yml.each{|h| hash[h.keys.first] = h.values.first}
    (yml + @legacy_urls).each {|pair| file.write pair.to_yaml unless hash[pair.keys.first] }
    file.close
  end

  def page_quantity(url)
    pagination = Nokogiri::HTML(open(url)).css("a").select{|n| n["href"].match(/page=\d/)}
    pagination.any? ? pagination.last['href'].split(/page=/).last.to_i : 0
  end

  def news_url_builder(base, year, month = 0, page = 0)
    "#{base}#{year}/#{month}/&page=#{page}"
  end

  def url_begin
    scheme + "://" + host
  end

  def url_checker(url)
    url.match(/^\/\S*/) ? url_begin + url : url
  end

end
