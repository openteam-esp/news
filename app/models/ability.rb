class Ability
  include CanCan::Ability

  def initialize(user=nil)
    user ||= (User.current || User.new)

    can :complete, Task do |task|
      task.executor == user
    end

    can :restore, Task do |task|
      task.executor == user && (task.next_task.nil? || task.next_task.fresh?)
    end


    ##################################
    ###           Entry            ###
    ##################################

    can :create, Entry do
      user.persisted?
    end

    can [:update, :destroy], Entry do | entry |
      entry.has_processing_task_executed_by? user
    end

    can :read, Entry do | entry |
      (user.roles.any? && !entry.draft?) || entry.has_participant?(user)
    end

    can :recycle, Entry do | entry |
      entry.deleted_by == user
    end

    if user && user.corrector?
      can :accept, Review
      can :restore, Review do |task|
        task.next_task.nil? || task.next_task.fresh?
      end

    end

    if user && user.publisher?
      can :accept, Publish
      can :restore, Publish do |task|
        task.next_task.nil? || task.next_task.fresh?
      end
    end

    can :create, Subtask do | subtask |
      user == subtask.issue.executor && subtask.issue.processing?
    end

    can :cancel, Subtask do | subtask |
      user == subtask.initiator
    end

    can :refuse, Subtask do | subtask |
      user == subtask.executor
    end

    can [:read, :fire_event], Task



    can :read, Asset do | asset |
      if asset.deleted_at?
        asset.entry.current_user_participant?
      else
        can? :read, asset.entry
      end
    end

    can [:create, :destroy], Asset do | asset |
      can? :edit, asset.entry
    end

    can [:read, :destroy], Message
    can [:create, :destroy], Subscribe

  end
end

