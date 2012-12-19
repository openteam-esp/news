# encoding: utf-8

module EspNewsSpecHelper
  def stub_message_maker
    MessageMaker.stub(:make_message)
  end

  def corrector_and_publisher
    @corrector_and_publisher ||= user.tap do |user|
      user.permissions.create!(:context => channel, :role => :corrector) unless user.corrector_of?(channel)
      user.permissions.create!(:context => channel, :role => :publisher) unless user.publisher_of?(channel)
    end
  end

  def channel
    @channel ||= Fabricate(:channel, :entry_type => 'news_entry')
  end

  def another_channel
    @another_channel ||= Fabricate(:channel, :entry_type => 'event_entry')
  end

  def draft
    Fabricate :news_entry, :initiator => initiator_of(channel)
  end

  def fresh_correcting
    @fresh_correcting ||= draft.tap do | entry |
      entry.prepare.complete!
    end
  end

  def processing_correcting
    @processing_correcting ||= fresh_correcting.tap do | entry |
      entry.current_user = corrector_of(channel)
      entry.review.accept!
    end
  end

  def fresh_publishing
    @fresh_publishing ||= processing_correcting.tap do | entry |
      entry.review.complete!
    end
  end

  def processing_publishing
    @processing_publishing ||= fresh_publishing.tap do | entry |
      entry.current_user = publisher_of(channel)
      entry.publish.accept!
    end
  end

  def published
    @published ||= processing_publishing.tap  do | entry |
      entry.channels << channel
      entry.publish.complete!
    end
  end

  def deleted_draft
    @deleted_draft ||=  draft.tap do | entry |
                          entry.move_to_trash
                        end
  end

  def revivified_draft
    @revivified_draft ||= deleted_draft.tap do | entry |
                            entry.revivify
                          end
  end
end

