class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    ## common
    can :manage, Context do |context|
      user.manager_of? context
    end

    can :manage, Permission do |permission|
      user.manager_of?(permission.context)
    end

    can :manage, Permission do |permission|
      permission.context.is_a?(Channel) && user.manager_of?(permission.context.context)
    end

    can [:new, :create], Permission do |permission|
      !permission.context && user.manager?
    end

    can [:search, :index], User if user.manager?

    can :manage, :application do
      user.have_permissions?
    end

    can :manage, :permissions do
      user.manager?
    end

    ## app specific
    can :manage, :channels if user.permissions.for_role(:manager).for_context_type(Context).exists?

    can :manage, Channel do |channel|
      user.manager_of? channel.context
    end

    can [:new, :create], Channel do |channel|
      !channel.context && user.manager?
    end

    ##################################
    ###           Task             ###
    ##################################
    can :manage, Task if user.manager?
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
    can :create, AnnouncementEntry if user.context_tree_of(Channel).map(&:entry_type).include?("announcement_entry")
    can :create, EventEntry if user.context_tree_of(Channel).map(&:entry_type).include?("event_entry")
    can :create, NewsEntry if user.context_tree_of(Channel).map(&:entry_type).include?("news_entry")

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
      can [:create, :destroy], Following do |following|
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
