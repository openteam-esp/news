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

  def corrector_role
    @corrector_role ||= (Role.corrector || Fabricate(:role, :kind => :corrector))
  end

  def corrector
    @corrector ||= create_corrector
  end

  def create_corrector
    user = Fabricate(:user)
    user.roles << corrector_role
    user
  end

  def publisher_role
    @publisher_role ||= (Role.publisher || Fabricate(:role, :kind => :publisher))
  end

  def publisher
    @publisher ||= create_publisher
  end

  def create_publisher
    user = Fabricate(:user)
    user.roles << publisher_role
    user
  end

  def channel
    @channel ||= Fabricate(:channel)
  end

  def create_entry(previous_state, event, options, user=nil)
    current_user = User.current
    set_current_user(user) if user

    entry = self.send("#{previous_state}_entry").clone
    entry.attributes = options
    entry.save

    entry.events.create! :kind => event
    set_current_user(current_user)
    entry.reload
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
    entry.reload
  end

  def awaiting_correction_entry(options = {})
    @awaiting_correction_entry ||= create_entry :draft, :request_correcting, options
  end

  def correcting_entry(options = {})
    @correcting_entry ||= create_entry :awaiting_correction, :accept_correcting, options, corrector
  end

  def awaiting_publication_entry(options = {})
    @awaiting_publication_entry ||= create_entry :correcting, :request_publicating, options, corrector
  end

  def publicating_entry(options = {})
    @publicating_entry ||= create_entry :awaiting_publication, :accept_publicating, options, publisher
  end

  def published_entry(options = {})
    entry = create_entry :publicating, :publish, options.merge(:channel_ids => [channel.id]), publisher
    @published_entry ||= create_entry :publicating, :publish, options.merge(:channel_ids => [channel.id]), publisher
  end

  def trash_entry(options = {})
    @trash_entry ||= create_entry :draft, :to_trash, options, initiator
  end

end

