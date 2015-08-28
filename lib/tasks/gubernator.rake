require 'gubernator/parser'
require 'gubernator/interview_parser'
require 'gubernator/gallery_parser'
require 'gubernator/video_parser'

namespace :gubernator do
  desc "fetch news from http://gubernator.tomsk.ru/news"
  task :news => :environment do
    Parser.new("http://gubernator.tomsk.ru/news", 166).parse
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
end
