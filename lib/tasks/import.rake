# encoding: utf-8

desc "import old data"
task :import => :environment do
  print 'loading yaml ....'
  hashes = YAML.load_file ENV['from']
  puts ' ok'

  bar = ProgressBar.new hashes.count

  user = User.find_or_create_by_uid '1'

  hashes.each do |hash|
    if (entry = Entry.where(:vfs_path => hash['vfs_path']).first)
      ActiveRecord::Base.record_timestamps = false
      hash.delete 'type'
      entry.update_attributes hash
      ActiveRecord::Base.record_timestamps = true
    else
      Timecop.freeze hash['created_at'] do
        type = hash.delete('type')
        entry = type.constantize.folder(:draft, user).new hash
        entry.current_user = user
        entry.save!
      end

      Timecop.freeze hash['updated_at'] do
        entry.prepare.entry.current_user = user
        entry.prepare.complete

        entry.review.accept
        entry.review.complete

        entry.publish.accept
        entry.publish.complete
      end
    end

    bar.increment!
  end
end
