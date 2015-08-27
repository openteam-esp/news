require 'gubernator/parser'
require 'gubernator/interview_parser'
require 'gubernator/gallery_parser'

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

  desc "fetch news from http://gubernator.tomsk.ru/photo"
  task :gallery => :environment do
    GalleryParser.new("http://gubernator.tomsk.ru/photo#albums", 169).parse
  end
end
