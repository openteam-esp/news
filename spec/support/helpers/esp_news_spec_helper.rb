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

  def another_corrector_and_publisher
    @another_corrector_and_publisher ||= another_user.tap do |user|
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

  def create_entry(state, prefix=nil)
    @entries ||= {}
    @entries["#{prefix}#{state}"] ||= Fabricate :news_entry, :initiator => initiator_of(channel)
  end

  [nil, 'another_'].each do | prefix |
    class_eval <<-END
      def #{prefix}draft
        create_entry('draft', "#{prefix}")
      end

      def #{prefix}fresh_correcting
        @#{prefix}fresh_correcting ||= #{prefix}draft.tap do | entry |
                                entry.prepare.complete!
                              end
      end

      def #{prefix}processing_correcting
        @#{prefix}processing_correcting ||= #{prefix}fresh_correcting.tap do | entry |
                                      entry.current_user = #{prefix}corrector
                                      entry.review.accept!
                                    end
      end

      def #{prefix}fresh_publishing
        @#{prefix}fresh_publishing ||= #{prefix}processing_correcting.tap do | entry |
                                entry.review.complete!
                              end
      end

      def #{prefix}processing_publishing
        @#{prefix}processing_publishing ||= #{prefix}fresh_publishing.tap do | entry |
                                    entry.current_user = #{prefix}publisher
                                    entry.publish.accept!
                                   end
      end

      def #{prefix}published
        @#{prefix}published ||= #{prefix}processing_publishing.tap  do | entry |
                         entry.channels << channel
                         entry.publish.complete!
                       end
      end
    END
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

