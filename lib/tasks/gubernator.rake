require 'gubernator/parser'

namespace :gubernator do
  desc "fetch news from http://gubernator.tomsk.ru/news"
  task :news => :environment do
    Parser.new("http://gubernator.tomsk.ru/news", 166).parse
  end

  desc "fetch news from http://gubernator.tomsk.ru/words"
  task :words => :environment do
    Parser.new("http://gubernator.tomsk.ru/words", 167, ".b-blog-item").parse
  end
end
