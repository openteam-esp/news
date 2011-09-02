# encoding: utf-8

desc "migrate old data"
task :migrate => :environment do
  %w[attachment_file picture event associate_attachments_with_entry copy_file recipient].each do | migrator |
    print "migrate #{migrator} ."
    "migrator/#{migrator}".classify.constantize.new.migrate
    puts " ok"
  end
end
