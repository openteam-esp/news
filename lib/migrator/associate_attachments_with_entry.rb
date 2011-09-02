class Migrator::AssociateAttachmentsWithEntry
  def migrate
    Asset.all.each do | asset |
      entry = Entry.find_by_old_id(asset.entry_id)
      asset.update_attribute(:entry_id, entry.id) if entry
    end
  end
end
