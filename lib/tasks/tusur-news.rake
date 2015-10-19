require 'tusur-news/tusur_news_parser'
require 'tusur-news/smi'
require 'tusur-news/interview_parser'
require 'tusur-news/gallery_parser'
require 'tusur-news/video_parser'

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
    TusurNewsParser.new("http://www.tusur.ru/ru/news/index.html?path=", 4).parse_entry("http://www.tusur.ru/ru/news/index.html?path=2011/01/21.html", Entry.new(annotation: "27 сентября в ТУСУР состоялся квест «В поисках сокровищ. Кубок первокурсников -2015»."))
  end

  desc "rake for cleaning channel 4"
  task :clean4 => :environment do
    Channel.find(4).entries.map(&:destroy)
    puts "Новости в канале 4 удалены"
  end

  desc "fetch news from http://gubernator.tomsk.ru/interview"
  task :interviews => :environment do
    InterviewParser.new("http://gubernator.tomsk.ru/interview", 168).parse
  end

  desc "fetch photo from http://gubernator.tomsk.ru/photo"
  task :gallery => :environment do
    GalleryParser.new("http://gubernator.tomsk.ru/photo#albums", 169).parse
  end

  desc "fetch video from http://gubernator.tomsk.ru/video"
  task :video => :environment do
    VideoParser.new("http://gubernator.tomsk.ru/video", 170, ".b-videolist-block .b-videolist-thumb").parse
  end

  desc "fix annotation in gubernator news"
  task :fix_annotation => :environment do
    entries = Channel.find(ENV['channel_id'].to_i).entries
    counter = 0
    entries.each do |entry|
      if entry.annotation && entry.body
        annotation = entry.annotation.gsub(/&nbsp;|<span class=\"nobr\">|<\/span>|<p>|<\/p>/," ").squish
        entry_body = entry.body.gsub("&nbsp;"," ").gsub(/ dir="ltr"|<b>|<\/b>/,"").squish
        if entry_body.match("<p>#{annotation}</p>")
          gsubed_body = entry_body.gsub("<p>#{annotation}</p>","")
          entry.update_attribute(:body, gsubed_body)
          counter+=1
        end
      end
    end
    puts "#{counter} news updated"
  end
end
