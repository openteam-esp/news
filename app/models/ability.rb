class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user
    can :manage, :all
    return
    ##################################
    ###           Task             ###
    ##################################
    can :fire_event, Task do | task |
      can?(:read, task.entry) && !task.deleted?
    end
    can [:complete, :refuse], Task do |task|
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
    can [:accept, :restore], Publish do | task |
      user.publisher?
    end

    ##################################
    ###           Subtask          ###
    ##################################
    can :create, Subtask do | subtask |
      user == subtask.issue.executor && subtask.issue.processing? && !subtask.issue.deleted?
    end
    can :accept, Subtask do | subtask |
      user == subtask.executor
    end
    can :cancel, Subtask do | subtask |
      user == subtask.initiator
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
      user.have_permissions? && !entry.draft?
    end
    can :read, Entry do | entry |
      entry.has_participant?(user)
    end
    can :read, Entry do | entry |
      entry.published?
    end

    can :revivify, Entry do | entry |
      entry.deleted_by == user
    end

    can :unlock, Entry do | entry |
      [entry.locked_by, entry.processing_issue.executor].include? user
    end

    ##################################
    ###           Event            ###
    ##################################
    can :read, Event

    ##################################
    ###           Following        ###
    ##################################
    if user.have_permissions?
      can [:create, :destroy], Following do | following |
        following.follower == user
      end
    end

    can :manage, :application do
      true
    end

    can :manage, :permissions do
      user.manager?
    end
  end
end

