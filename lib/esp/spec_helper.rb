# encoding: utf-8

module Esp::SpecHelper

  def set_current_user(user = nil)
    user ||= initiator
    User.current = user
  end

  def initiator(options={})
    @initiator ||= create_initiator(options)
  end

  def create_initiator(options={})
    Fabricate(:user, options)
  end

  def another_initiator(options={})
    @another_initiator ||= create_initiator(options)
  end

  def corrector
    @corrector ||= create_corrector
  end

  def create_corrector
    Fabricate.build(:user, :roles => [:corrector])
  end

  def publisher
    @publisher ||= create_publisher
  end

  def create_publisher
    Fabricate(:user, :roles => [:publisher])
  end

  def corrector_and_publisher
    @corrector_and_publisher ||= create_corrector_and_publisher
  end

  def other_corrector_and_publisher
    @other_corrector_and_publisher ||= create_corrector_and_publisher
  end

  def create_corrector_and_publisher
    Fabricate(:user, :roles => [:corrector, :publisher])
  end

  def channel
    @channel ||= Fabricate(:channel)
  end

  def create_entry(previous_state, event, options, user=nil)
    current_user = User.current
    set_current_user(user) if user

    entry = self.send("#{previous_state}_entry").clone
    entry.update_attributes options

    entry.events.create! :kind => event
    set_current_user(current_user)
    entry.reload
  end

  def draft_entry(options = {})
    @draft_entry ||= create_draft_entry(options)
  end

  def create_draft_entry(options = {})
    set_current_user(User.current)
    draft.save
    draft
  end

  Entry.enums[:state].each do | state |
    define_method "build_#{state}" do | *args |
      options = (args.last || Hash.new).merge :state => state.to_s, :initiator_id => initiator.id
      Fabricate.build(:entry, options)
    end

    define_method "#{state}" do | *args |
      instance_variable_get("@#{state}") || instance_variable_set("@#{state}", self.send("build_#{state}", *args))
    end

    define_method "stored_#{state}" do | *args |
      instance_variable_get("@stored_#{state}") ||  self.send(state, *args).tap do | entry |
                                                      entry.save!
                                                      entry.reload
                                                      instance_variable_set("@stored_#{state}", entry)
                                                    end
    end
  end

  def processing_correcting
    @processing_correcting ||= stored_draft.tap do | entry |
                                 entry.prepare.complete!
                                 entry.review.accept!
                               end
  end

  def processing_publishing
    @processing_publishing ||= processing_correcting.tap do | entry |
                                 entry.review.complete!
                                 entry.publish.accept!
                               end
  end

  def draft_entry_with_asset(options = {})
    @draft_entry_with_asset ||= create_draft_entry_with_asset(options)
  end

  def create_draft_entry_with_asset(options = {})
    entry = create_draft_entry(options)
    entry.update_attribute :assets_attributes, [Fabricate.attributes_for(:asset)]
    entry.reload
  end

end

