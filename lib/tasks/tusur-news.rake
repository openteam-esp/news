require 'tusur-news/tusur_news_parser'
require 'tusur-news/interview_parser'
require 'tusur-news/gallery_parser'
require 'tusur-news/video_parser'

namespace :tusur do
  desc "fetch news from http://www.tusur.ru"
  task :news => :environment do
    TusurNewsParser.new("http://www.tusur.ru/ru/news/index.html?path=", 4).parse
  end

  task :test => :environment do
    TusurNewsParser.new("http://www.tusur.ru/ru/news/index.html?path=", 4).parse_entry("http://www.tusur.ru/ru/news/index.html?path=2015/10/01.html", "blabla")
  end

  desc "fetch news from http://gubernator.tomsk.ru/words"
  task :words => :environment do
    Parser.new("http://gubernator.tomsk.ru/words", 167, ".b-blog-item").parse
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