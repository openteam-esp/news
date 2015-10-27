namespace :tusur do
  desc "fetch news from http://www.tusur.ru"
  task :news => :environment do
    TusurNewsParser.new("http://www.tusur.ru/ru/news/index.html?path=", 4).parse
  end

  desc "fetch announces from http://www.tusur.ru"
  task :announces => :environment do
    TusurNewsParser.new("http://www.tusur.ru/ru/announcements/index.html?path=", 7).parse
  end

  desc "fetch SMI about TUSUR from http://www.tusur.ru"
  task :smi => :environment do
    SmiParser.new("http://www.tusur.ru/ru/tusur/smi/", 8).parse
  end

  desc "rake for testing parser code"
  task :test => :environment do
    TusurNewsParser.new("http://www.tusur.ru/ru/news/index.html?path=", 4).parse_entry("http://www.tusur.ru/ru/news/index.html?path=2015/07/02.html", Entry.new(annotation: "27 сентября в ТУСУР состоялся квест «В поисках сокровищ. Кубок первокурсников -2015»."))
  end

  desc "rake for cleaning channel 4"
  task :clean4 => :environment do
    Channel.find(4).entries.map(&:destroy)
    puts "Новости в канале 4 удалены"
  end

  desc "fetch releases from http://www.tusur.ru"
  task :releases => :environment do
    ReleasesParser.new("http://www.tusur.ru/ru/smi/", 9).parse
  end

  desc "fetch gallerys from http://www.tusur.ru"
  task :gallery => :environment do
    TusurGalleryParser.new("http://www.tusur.ru/ru/tusur/gallery.html", 10).parse
  end

  desc "fetch tusur-tv from http://www.tusur.ru"
  task :youtube => :environment do
    YoutubeParser.new("UC81Ox-2oL5_nFfRMve7uCGg").import
  end
end
