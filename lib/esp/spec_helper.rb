# encoding: utf-8

module Esp::SpecHelper

  def set_current_user(user = nil)
    user ||= initiator
    User.current = user
  end

  def as(user, &block)
    logged_in = User.current
    User.current = user
    result = yield
    User.current = logged_in
    result
  end

  def another_initiator(options={})
    @another_initiator ||= create_user(options)
  end

  def initiator(options={})
    @initiator ||= create_user(options)
  end

  def corrector
    @corrector ||= create_user(:roles => :corrector)
  end

  def another_corrector
    @another_corrector ||= create_user(:roles => :corrector)
  end

  def publisher
    @publisher ||= create_user(:roles => :publisher)
  end

  def another_publisher
    @another_publisher ||= create_user(:roles => :publisher)
  end

  def corrector_and_publisher
    @corrector_and_publisher ||= create_user(:roles => [:corrector, :publisher])
  end

  def create_user(options={})
    Fabricate(:user, options)
  end


  def channel
    @channel ||= Fabricate(:channel)
  end

  def draft(options={})
    @draft ||= create_draft(options)
  end

  def create_draft(options={})
    as initiator do Fabricate(:entry, options) end
  end

  def fresh_correcting(options={})
    @fresh_correcting ||=  draft(options).tap do | entry |
                            as initiator do entry.prepare.complete! end
                           end
  end

  def processing_correcting
    @processing_correcting ||=  fresh_correcting.tap do | entry |
                                  as corrector do entry.review.accept! end
                                end
  end

  def fresh_publishing
    @fresh_publishing ||= processing_correcting.tap do | entry |
                            as corrector do entry.review.complete! end
                          end
  end

  def processing_publishing
    @processing_publishing ||= fresh_publishing.tap do | entry |
                                as publisher do entry.publish.accept! end
                               end
  end

  def published
    @published ||= processing_publishing.tap  do | entry|
                     as publisher do entry.publish.complete! end
                   end
  end

end

