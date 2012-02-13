# encoding: utf-8
#require 'sunspot_matchers'
#Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
#STDOUT.sync = true

desc "migrate old data"
task :migrate => :environment do
  print "migrate entries "
  LegacyEntry.migrate(STDOUT)
  puts " ok"
end
