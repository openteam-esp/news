# encoding: utf-8

desc "migrate old data"
task :migrate => :environment do
  print "migrate entries "
  Migrator::Entry.new(STDOUT).migrate
  puts " ok"
end
