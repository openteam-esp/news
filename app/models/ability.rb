class Ability
  include CanCan::Ability

  def initialize(user=nil)
    user = user
    #################
    #  casual user  #
    #################

    can [:create, :read, :rss], Entry
    can [:read, :destroy], Message
    can [:create, :destroy], Subscribe
    can [:create, :read, :destroy], Asset

    can [:edit], Entry do |entry|
      can :create, entry.events.build(:kind => :store)
    end

    can :create, Event do |event|
      event.entry.permitted_events.include? event.kind.to_sym
    end

  end
end

