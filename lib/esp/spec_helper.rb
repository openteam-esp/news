module Esp::SpecHelper

  def set_current_user(user=nil)
    user ||= create_initiator
    User.current = user
  end

  def initiator
    @initiator ||= create_initiator
  end

  def create_initiator
    Fabricate(:user)
  end

  def draft_entry(options = {})
    @draft_entry ||= create_draft_entry(options)
  end

  def create_draft_entry(options = {})
    set_current_user
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

  def awaiting_correction_entry
    @awaiting_correction_entry ||= create_awaiting_correction_entry
  end

  def create_awaiting_correction_entry
    entry = create_draft_entry
    entry.events.create(:kind => 'send_to_corrector')
    entry
  end

  def returned_to_author_entry
    @returned_to_author_entry ||= create_returned_to_author_entry
  end

  def create_returned_to_author_entry
    entry = create_awaiting_correction_entry
    entry.events.create(:kind => 'return_to_author')
    entry
  end

  def correcting_entry
    @correcting_entry ||= create_correcting_entry
  end

  def create_correcting_entry
    entry = create_awaiting_correction_entry
    entry.events.create :kind => 'correct'
    entry
  end

  def awaiting_publication_entry
    @awaiting_publication_entry ||= create_awaiting_publication_entry
  end

  def create_awaiting_publication_entry
    entry = create_correcting_entry
    entry.events.create(:kind => 'send_to_publisher')
    entry
  end

  def returned_to_corrector_entry
    @returned_to_corrector_entry ||= create_returned_to_corrector_entry
  end

  def create_returned_to_corrector_entry
    entry = create_awaiting_publication_entry
    entry.events.create(:kind => 'return_to_corrector')
    entry
  end

  def published_entry
    @published_entry ||= create_published_entry
  end

  def create_published_entry
    entry = create_awaiting_publication_entry
    entry.events.create(:kind => 'publish')
    entry
  end

  def trashed_entry
    @trashed_entry ||= begin
                         set_current_user
                         entry = Fabricate(:entry)
                         entry.events.create(:kind => 'to_trash')
                         entry
                       end

  end

  def restored_entry
    @restored_entry ||= begin
                          set_current_user
                          entry = Fabricate(:entry)
                          entry.events.create(:kind => 'to_trash')
                          entry.events.create(:kind => 'restore', :user => User.current)
                          entry
                        end
  end

  def immediately_published_entry
    @immediately_published_entry ||= begin
                                       set_current_user
                                       entry = Fabricate(:entry)
                                       entry.events.create(:kind => 'immediately_publish')
                                       entry
                                     end
  end

  def immediately_sended_to_publisher_entry
    @immediately_sended_to_publisher_entry ||= begin
                                                 set_current_user
                                                 entry = Fabricate(:entry)
                                                 entry.events.create(:kind => 'immediately_send_to_publisher')
                                                 entry
                                               end
  end

end

