class Ability
  include CanCan::Ability

  def initialize(user=nil)
    user = user || User.current || User.new

    #################
    #  casual user  #
    #################

    can [:create, :rss], Entry
    can :read, Entry do | entry |
      entry.published? || entry.current_user_participant? || (!(entry.draft? || entry.trash?) && (entry.current_user_corrector? || entry.current_user_publisher?))
    end

    can :edit, Entry do |entry|
      can? :create, Event.new(:entry => entry, :kind => :store)
    end

    can :create, Event do |event|
      event.entry.permitted_events.include? event.kind.to_sym
    end

    can [:read, :destroy], Message
    can [:create, :destroy], Subscribe
    can [:create, :read, :destroy], Asset

  end
end

