desc 'Clear stale entries'
task :clear => :environment do
  Entry.stale.destroy_all
end
