class DestroyEntryJob < Struct.new(:entry_id)
  def perform
    Entry.find(entry_id).destroy_without_trash
  end
end
