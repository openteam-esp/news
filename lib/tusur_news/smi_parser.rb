class SmiParser < TusurNewsParser

  def parse
    years = 2004..Date.today.year
    pb = ProgressBar.new(years.count)
    years.each do |year|
      pb.increment!
      puts "importing #{year}"
      (0..page_quantity(smi_url_builder(year))).each do |page_number|
        paginated_url = "#{@url}#{year}/index.html?page=#{page_number}"
        puts paginated_url
        fetch_entries(paginated_url)
      end
    end
    puts "Errors:"
    @error_counter.each do |key, value|
      puts key
      puts value
    end
    write_to("legacy_urls_smi.yml")
  end


  def parse_entry(news_url, entry)
    #puts news_url
    page = Nokogiri::HTML(open(news_url)).css("#center-side-full")                        #страница
    time = get_time(page)                                                                 #время публикации
    body = get_body(page, entry)                                                          #контент страницы
    begin
      recursive_node_cleaner(body.at_css("p"), "", %w(p span br text )) if entry.annotation && body.at_css("p").text.squish == entry.annotation.squish #чистим контент первого p от лишних span
    rescue
      @error_counter[news_url] = "Проблема с первым абзацем"
    end
    gallery = body.css(".colorbox").map(&:remove)                                         #фотографии с .colorbox вырезаем и отправляем в галерею
    remove_duplicate_links(body, gallery)
    update_files_src body, entry.vfs_path                                                 #перекладываем файлы на сторадж и апдейтим ссылки на них
    update_inner_images_src body, entry.vfs_path                                          #перекладываем оставшиеся после резни изображения на сторадж и обновляем им ссылки
    update_links body
    update_iframes(body)                                                                  #iframe с ссылками на youtube заменяем на p с ссылкой
    update_objects(body)                                                                  #апдейтим objects с ссылками на старый тусур и youtube

    page.children.select{|n| n["style"].present? && n["style"].match("text-align: right")}.map(&:remove) #чистим от нод-подписей
    recursive_node_cleaner(body, /^$/, %w(br p span text))                                #чистим тело новости от пустых элементов
    check_for_bad_images(body)
    return  { body: body.children.to_html.squish.gsub('<p>&nbsp;</p>', ''), time: time,  gallery: gallery, source: {} }
  end

  def smi_url_builder(year)
    "#{url}#{year}/"
  end


  def get_body(page, entry)
    title, source = entry.title.split('//').map(&:squish)
    header_node = (page.at_css("h1") || page.at_css("h2") || page.at_css("h3"))
    header_node.remove if header_node
    header_text = (header_node ? header_node.text : "")
    author = title.gsub(header_text, '').squish
    entry.author = sanitize_author(author)
    entry.title  = header_text.present? ? header_text : title
    entry.source = sanitize_source(source || "")
    page
  end

  def get_time(page)
    Time.zone.parse page.css(".updated_at").remove.text
  end

  def new_entry?(entry)
    channel.entries.where(:annotation => entry.annotation).empty?
  end

  def sanitize_source(string)
    replacements = {
      ""                => /3.июля/ ,
      "Томские Новости" => /^Томские новости/ ,
      "Томский Вестник" => /То.*ский вестник/i ,
      "Ёж (Молодежное приложение к газете «Томские новости»)" => /Ёж/,
      "Аргументы и Факты Томск" => /АиФ|Аргументы/ ,
      "Здоровье ONLINE. – 3 апреля. – 2011" => /Антон/,
      "Бизнес-журнал" => /Бизнес-журнал/,
      "Бизнес-журнал. Томск" => /Томский бизнес/,
      "БиТ: Бизнес и Техника" => /it-magazine/,
      "vesti70.ru" => /Веб-сайт/,
      "Вести-Томск" => /Вести.+томск/i,
      'ГТРК "Томск"' => /Г.+К-Томск/,
      "Живое ТВ" => /Живое/,
      "ИА Интефакс-Сибирь" => /Интерфакс-сибирь/i,
      "ИА Интерфакс" => /Интерфакс – Россия/,
      "PC week" => /PCweek/,
      "Комсомольская правда в Томске" => /КП/,
      "Комсомольская правда в Томске" => /правда.*томск/i,
      "Континент–Сибирь" => /Континент – Сибирь/,
      "Красное Знамя" => /Красное Знамя/i,
      "Московский Комсомолец в Томске" => /МК в Томске/,
      "Наука и технологии РФ" => /Наука.*РФ/i,
      "РИА Новости" => /РИА.*Новости/i,
      "Работа и обучение" => /Работа/,
      "Российская газета" => /Российская газета/,
      "Территория Интеллекта " => /Территория Интеллекта/i,
      "TOMCK magazine" => /томск.*agazine/i,
      "УниверCITY" => /Универ.*TY/,
      "Час Пик" => /Час.Пик/
    }

    if string.present?
      array = string.split(".")
      replacements.each do |k, v|
        if array.first.match(v)
          array[0] = k
          break
        end
      end
      array.join(".")
    else
      ""
    end
  end

  def sanitize_author(string)
    return "" if string.nil?
    (string.match(/^[А-Я]{1}[а-я]+\s[А-Я]{1}[.]/) || "").to_s
  end
end
