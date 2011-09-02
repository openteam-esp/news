class Migrator::Entry
  def migrate
    Legacy::Entry.record_timestamps = false
    Legacy::Entry.find_each do | legacy_entry |
      entry = Entry.find_or_initialize_by_legacy_id(legacy_entry.id)
      entry.title         = legacy_entry.title.squish
      entry.annotation    = legacy_entry.annotation.squish
      entry.body          = legacy_entry.body_as_html
      entry.created_at    = legacy_entry.created_at
      entry.updated_at    = legacy_entry.updated_at
      entry.since         = legacy_entry.date_time
      entry.until         = legacy_entry.end_date_time
      entry.state         = legacy_entry.state
      entry.save :validate => false
      entry.channel_ids   = legacy_entry.channel_ids
      legacy_entry.assets.each do | legacy_asset |
        asset = entry.assets.find_or_initialize_by_legacy_id legacy_asset.id
        asset.file = File.open(legacy_asset.file.path)
        asset.save :validate => false
      end
    end
  end
end

