# encoding: utf-8

desc "migrate old data"
task :migrate => :environment do
  print "migrate entries "
  LegacyEntry.migrate(STDOUT)
  puts " ok"
end
