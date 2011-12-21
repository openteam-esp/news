# encoding: utf-8


require Rails.root.join('app/models/entry')
require Rails.root.join('app/models/tasks/issue')

class Array
  def update_all(options)
    self.each { |record| record.update_attributes options }
  end
end

class Issue
  def subtasks_opened
    subtasks_opened = []
    subtasks.each do |subtask|
      subtasks_opened << subtask if subtask.fresh? || subtask.processing?
    end
    subtasks_opened
  end
end

class Entry
  def tasks
    [prepare, review, publish].map{|issue| [issue, issue.subtasks]}.flatten
  end

  def has_processing_task_executed_by?(user)
    tasks.select(&:processing?).map(&:executor).include? user
  end

  def has_participant?(user)
    tasks.map(&:executor).include?(user) || tasks.map(&:initiator).include?(user)
  end

  def channel_ids
    channels.map(&:id)
  end

end

module EspSpecHelper

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

  def deleted_draft(options={})
    @deleted_draft ||= draft(options).tap do | entry |
                         as initiator do
                           entry.destroy
                         end
                       end
  end

  def recycled_draft(options={})
    @recycled_draft ||= deleted_draft(options).tap do | entry |
                          as initiator do entry.recycle end
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

