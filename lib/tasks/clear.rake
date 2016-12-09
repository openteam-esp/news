desc 'Clear stale entries'
task clear: :environment do
  Entry.stale.map(&:destroy)
end
