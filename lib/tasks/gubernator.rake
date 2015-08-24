require 'gubernator/parser'

namespace :gubernator do
  desc "fetch news from http://gubernator.tomsk.ru/news"
  task :news => :environment do
    Parser.new(ENV['URL'], ENV['CHANNEL']).parse
    #Parser.new(ENV['URL'], ENV['CHANNEL']).fetch_entries("http://gubernator.tomsk.ru/news/page/2")
  end
end
