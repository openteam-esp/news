class Ability
  include CanCan::Ability

  def initialize(user=nil)
    user ||= (User.current || User.new)

    ##################################
    ###           Task             ###
    ##################################
    can :fire_event, Task do | task |
      can? :read, task.entry
    end
    can :complete, Task do |task|
      task.executor == user
    end
    can :refuse, Task do | task |
      task.executor == user
    end

    ##################################
    ###          Prepare           ###
    ##################################
    can :restore, Prepare do | task |
      task.executor == user
    end

    ##################################
    ###          Review            ###
    ##################################
    can [:accept, :restore], Review do | task |
      user.corrector?
    end

    ##################################
    ###          Publish           ###
    ##################################
    can [:accept, :restore], Publish do
      user.publisher?
    end

    ##################################
    ###           Subtask          ###
    ##################################
    can :create, Subtask do | subtask |
      user == subtask.issue.executor && subtask.issue.processing?
    end
    can :accept, Subtask do | subtask |
      user == subtask.executor
    end
    can :cancel, Subtask do | subtask |
      user == subtask.initiator
    end
    can :restore, Subtask do |task|
      task.executor == user
    end

    ##################################
    ###           Entry            ###
    ##################################
    can :create, Entry do
      user.persisted?
    end

    can :update, Entry do | entry |
      entry.has_processing_task_executed_by?(user) && entry.locked_by == user
    end
    can [:update, :destroy], Entry do | entry |
      entry.has_processing_task_executed_by?(user) && !entry.locked? && !entry.deleted?
    end

    can :read, Entry do | entry |
      user.roles.any? && !entry.draft?
    end
    can :read, Entry do | entry |
      entry.has_participant?(user)
    end
    can :read, Entry do | entry |
      entry.published?
    end

    can :recycle, Entry do | entry |
      entry.deleted_by == user
    end

    ##################################
    ###          Asset             ###
    ##################################
    can :read, Asset do | asset |
      if asset.deleted? || asset.entry.deleted?
        asset.has_participant?(user)
      else
        can? :read, asset.entry
      end
    end

    can [:create, :destroy], Asset do | asset |
      can? :update, asset.entry
    end

    can [:read, :destroy], Message
    can [:create, :destroy], Subscribe

    ##################################
    ###           Event            ###
    ##################################
    can :read, Event
  end
end

