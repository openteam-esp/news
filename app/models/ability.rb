class Ability
  include CanCan::Ability

  def initialize(user=nil)

    #################
    #  casual user  #
    #################

    can [:create], Entry

    can :read, Entry do | entry |
      entry.published? || entry.current_user_participant? || (!(entry.draft? || entry.trash?) && (entry.current_user_corrector? || entry.current_user_publisher?))
    end

    can :edit, Entry do |entry|
      can? :create, Event.new(:entry => entry, :kind => :store)
    end

    can :create, Event do |event|
      event.entry.permitted_events.include? event.kind.to_sym
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

