# encoding: utf-8


desc "dump entries from legacy db"
namespace :legacy do
  namespace :db do
    task :dump => :environment do
      require 'ya2yaml'
      File.open(Rails.root.join("db/entries.yml"), "w") do | file |
        file << Legacy::Entry.unscoped.order("id desc").limit(100).all.inject({}) { | hash, legacy_entry |
          hash[legacy_entry.id] = {
              'title' => legacy_entry.title,
              'annotation' => legacy_entry.migrated_annotation,
              'body' => legacy_entry.migrated_body,
              'created_at' => legacy_entry.created_at
          }
          hash
        }.ya2yaml
      end
    end
  end
end
