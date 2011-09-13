class Ability
  include CanCan::Ability

  def initialize(user=nil)
    user = User.current

    can [:complete], Issue do |issue|
      issue.executor == user && issue.processing?
    end


    #################
    #  casual user  #
    #################

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

