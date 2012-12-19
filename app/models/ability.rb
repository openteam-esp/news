class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :manage, :application

    ## app specific

    ##################################
    ###           Task             ###
    ##################################
    can :fire_event, Task do |task|
      can?(:read, task.entry) && !task.deleted?
    end
    can [:complete, :refuse], Task do |task|
      task.executor == user
    end

    ##################################
    ###          Prepare           ###
    ##################################
    can :restore, Prepare do |prepare|
      prepare.executor == user
    end

    ##################################
    ###          Review            ###
    ##################################
    can [:accept, :restore, :complete, :refuse], Review do |review|
      user.corrector?
    end

    ##################################
    ###          Publish           ###
    ##################################
    can [:accept, :restore, :complete, :refuse], Publish do |publish|
      user.publisher?
    end

    ##################################
    ###           Subtask          ###
    ##################################
    can :create, Subtask do |subtask|
      user == subtask.issue.executor && subtask.issue.processing? && !subtask.issue.deleted?
    end
    can :accept, Subtask do |subtask|
      user == subtask.executor
    end
    can :cancel, Subtask do |subtask|
      user == subtask.initiator
    end

    ##################################
    ###           Entry            ###
    ##################################
    can :create, AnnouncementEntry if Channel.subtree_for(user).where(:entry_type => 'announcement_entry').any?
    can :create, EventEntry if Channel.subtree_for(user).where(:entry_type => 'event_entry').any?
    can :create, NewsEntry if Channel.subtree_for(user).where(:entry_type => 'news_entry').any?

    can :update, Entry do |entry|
      entry.has_processing_task_executed_by?(user) && entry.locked_by == user
    end

    can [:update, :destroy], Entry do |entry|
      entry.has_processing_task_executed_by?(user) && !entry.locked? && !entry.deleted?
    end

    can :read, Entry do |entry|
      (user.corrector? || user.publisher? || user.manager?) && !entry.draft?
    end

    can :read, Entry do |entry|
      entry.has_participant?(user)
    end

    can :revivify, Entry do |entry|
      entry.deleted_by == user
    end

    can :unlock, Entry do |entry|
      [entry.locked_by, entry.processing_issue.try(:executor)].include? user
    end

    ##################################
    ###           Event            ###
    ##################################
    can :read, Event

    ##################################
    ###           Following        ###
    ##################################
    if user.permissions.any?
      can [:create, :destroy], Following do |following|
        following.follower == user
      end
    end
  end
end
