module Esp::SpecHelper

  def set_current_user(user = nil)
    user ||= initiator
    User.current = user
  end

  def initiator
    @initiator ||= create_initiator
  end

  def create_initiator
    Fabricate(:user)
  end

  def corrector
    @corrector ||= create_corrector
  end

  def create_corrector
    user = Fabricate(:user)
    user.roles << Role.corrector || Fabricate(:role, :kind => :corrector)
    user
  end

  def publisher
    @publisher ||= create_publisher
  end

  def create_publisher
    user = Fabricate(:user)
    user.roles << Role.publisher || Fabricate(:role, :kind => :publisher)
    user
  end

  def draft_entry(options = {})
    @draft_entry ||= create_draft_entry(options)
  end

  def create_draft_entry(options = {})
    set_current_user(User.current)
    Fabricate(:entry, options)
  end

  def draft_entry_with_asset(options = {})
    @draft_entry_with_asset ||= create_draft_entry_with_asset(options)
  end

  def create_draft_entry_with_asset(options = {})
    entry = create_draft_entry(options)
    entry.update_attribute :assets_attributes, [Fabricate.attributes_for(:asset)]
    entry
  end

  def awaiting_correction_entry(options = {})
    @awaiting_correction_entry ||= create_awaiting_correction_entry(options)
  end

  def create_awaiting_correction_entry(options = {})
    entry = create_draft_entry(options)
    entry.events.create!(:kind => :request_correcting)
    entry
  end

  def returned_to_author_entry(options = {})
    @returned_to_author_entry ||= create_returned_to_author_entry(options)
  end

  def create_returned_to_author_entry(options = {})
    entry = create_awaiting_correction_entry(options)
    entry.events.create!(:kind => :request_reworking)
    entry
  end

  def correcting_entry(options = {})
    @correcting_entry ||= create_correcting_entry(options)
  end

  def create_correcting_entry(options = {})
    entry = create_awaiting_correction_entry(options)
    entry.events.create! :kind => :accept_correcting
    entry
  end

  def awaiting_publication_entry(options = {})
    @awaiting_publication_entry ||= create_awaiting_publication_entry(options)
  end

  def create_awaiting_publication_entry(options = {})
    entry = create_correcting_entry(options)
    entry.events.create!(:kind => :request_publicating)
    entry
  end

  def returned_to_corrector_entry(options = {})
    @returned_to_corrector_entry ||= create_returned_to_corrector_entry(options)
  end

  def create_returned_to_corrector_entry(options = {})
    entry = create_awaiting_publication_entry(options)
    entry.events.create!(:kind => :request_correcting)
    entry
  end

  def publicating_entry(options = {})
    @published_entry ||= create_publicating_entry(options)
  end

  def create_publicating_entry(options = {})
    entry = create_awaiting_publication_entry(options)
    entry.events.create!(:kind => :accept_publicating)
    entry
  end

  def published_entry(options = {})
    @published_entry ||= create_published_entry(options)
  end

  def create_published_entry(options = {})
    entry = create_publicating_entry(options)
    entry.events.create!(:kind => :publish)
    entry
  end

  def trashed_entry(options = {})
    @trashed_entry ||= create_trashed_entry(options)
  end

  def create_trashed_entry(options = {})
    entry = create_draft_entry(options)
    entry.events.create!(:kind => 'to_trash')
    entry
  end


  def untrashed_entry(options = {})
    @untrashed_entry ||= create_untrashed_entry(options)
  end

  def create_untrashed_entry(options = {})
    entry = create_trashed_entry(options)
    entry.events.create!(:kind => 'untrash')
    entry
  end

end

