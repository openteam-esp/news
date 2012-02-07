# encoding: utf-8

module EspNewsSpecHelper

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

  def another_initiator
    @another_initiator ||= another_user
  end

  def initiator
    @initiator ||= user
  end

  def corrector
    @corrector ||= corrector_of(root)
  end

  def another_corrector
    @another_corrector ||= another_corrector_of(root)
  end

  def publisher
    @publisher ||= publisher_of(root)
  end

  def another_publisher
    @another_publisher ||= another_publisher_of(root)
  end

  def corrector_and_publisher
    @corrector_and_publisher ||= user.tap do |user|
      user.permissions.create!(:context => root, :role => :corrector) unless user.corrector_of?(root)
      user.permissions.create!(:context => root, :role => :publisher) unless user.publisher_of?(root)
    end
  end

  def another_corrector_and_publisher
    @another_corrector_and_publisher ||= another_user.tap do |user|
      user.permissions.create!(:context => root, :role => :corrector) unless user.corrector_of?(root)
      user.permissions.create!(:context => root, :role => :publisher) unless user.publisher_of?(root)
    end
  end
  def channel
    @channel ||= Fabricate(:channel)
  end

  def draft(options={})
    @draft ||= create_draft(options)
  end

  def deleted_draft(options={})
    @deleted_draft ||= draft(options).tap do | entry |
                         as initiator do
                           entry.destroy
                         end
                       end
  end

  def revivified_draft(options={})
    @revivified_draft ||= deleted_draft(options).tap do | entry |
                          as initiator do entry.revivify end
                        end
  end

  def create_draft(options={})
    as initiator do Fabricate(:entry, options) end
  end

  def fresh_correcting(options={})
    @fresh_correcting ||=  draft(options).tap do | entry |
                            as initiator do entry.prepare.complete! end
                           end
  end

  def processing_correcting(options={})
    @processing_correcting ||=  fresh_correcting(options).tap do | entry |
                                  as corrector do entry.review.accept! end
                                end
  end

  def fresh_publishing(options={})
    @fresh_publishing ||= processing_correcting(options).tap do | entry |
                            as corrector do entry.review.complete! end
                          end
  end

  def processing_publishing(options={})
    @processing_publishing ||= fresh_publishing(options).tap do | entry |
                                as publisher do entry.publish.accept! end
                               end
  end

  def published(options={})
    @published ||= processing_publishing(options).tap  do | entry |
                     as publisher do
                       entry.channels << channel
                       entry.publish.complete!
                     end
                   end
  end

  def prepare_subtask_for(executor)
    @prepare_subtask_for ||= as initiator do draft.prepare.subtasks.create!(:description => "подзадача", :executor => executor) end
  end

  def review_subtask_for(executor)
    @review_subtask_for ||= as corrector do processing_correcting.review.subtasks.create!(:description => "подзадача", :executor => executor) end
  end

end

