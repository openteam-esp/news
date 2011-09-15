class Ability
  include CanCan::Ability

  def initialize(user=nil)
    user ||= (User.current || User.new)

    can :complete, Task do |task|
      task.executor == user
    end

    can :restore, Task do |task|
      task.executor == user && (task.entry.next_task(task).nil? || task.entry.next_task(task).fresh?)
    end

    if user && user.corrector?
      can :accept, Review
      can :restore, Review do |task|
        task.entry.next_task(task).nil? || task.entry.next_task(task).fresh?
      end

    end

    if user && user.publisher?
      can :accept, Publish
      can :restore, Publish do |task|
        task.entry.next_task(task).nil? || task.entry.next_task(task).fresh?
      end
    end


    #################
    #  casual user  #
    #################

    can :read, Task

    can [:create], Entry

    can :read, Entry do | entry |
      true
    end

    can :edit, Entry do |entry|
      true
    end

    can :create, Event do |event|
      true
    end

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

