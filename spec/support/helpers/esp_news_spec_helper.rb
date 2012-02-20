# encoding: utf-8

module EspNewsSpecHelper

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
    @channel ||= Fabricate(:channel, :polymorphic_context => "context_#{root.id}")
  end

  def draft(options={})
    @draft ||= create_draft(options)
  end

  def deleted_draft(options={})
    @deleted_draft ||=  draft(options).tap do | entry |
                          entry.move_to_trash
                        end
  end

  def revivified_draft(options={})
    @revivified_draft ||= deleted_draft(options).tap do | entry |
                            entry.revivify
                          end
  end

  def create_draft(options={})
    Fabricate :news_entry, {:current_user => initiator, :initiator => initiator}.merge(options)
  end

  def fresh_correcting(options={})
    @fresh_correcting ||= draft(options).tap do | entry |
                            entry.prepare.complete!
                          end
  end

  def processing_correcting(options={})
    @processing_correcting ||= fresh_correcting(options).tap do | entry |
                                  entry.current_user = corrector
                                  entry.review.accept!
                                end
  end

  def fresh_publishing(options={})
    @fresh_publishing ||= processing_correcting(options).tap do | entry |
                            entry.review.complete!
                          end
  end

  def processing_publishing(options={})
    @processing_publishing ||= fresh_publishing(options).tap do | entry |
                                entry.current_user = publisher
                                entry.publish.accept!
                               end
  end

  def published(options={})
    @published ||= processing_publishing(options).tap  do | entry |
                     entry.channels << channel
                     entry.publish.complete!
                   end
  end

  def prepare_subtask_for(executor)
    @prepare_subtask_for ||= draft.prepare.subtasks.create!(:description => "подзадача", :executor => executor)
  end

  def review_subtask_for(executor)
    @review_subtask_for ||= processing_correcting.review.subtasks.create!(:description => "подзадача", :executor => executor)
  end

end

