class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    #################
    #  casual user  #
    #################

    can [:create, :read], Entry

    can :update, Entry do |entry|
      entry.draft? && entry.initiator == user
    end

    can :create, Event do |event|
      %w[send_to_corrector to_trash].include?(event.type) && event.entry.initiator == user
    end

    can :create, Event do |event|
      %w[restore].include?(event.type) && event.entry.related_to(user) && event.entry.trash?
    end

    #################
    #   corrector   #
    #################

    if user.corrector?
      can :create, Event do |event|
        %w[immediately_send_to_publisher to_trash].include?(event.type) && event.entry.initiator == user
      end

      can :create, Event do |event|
        %w[correct return_to_author to_trash].include?(event.type) && event.entry.awaiting_correction?
      end

      can :create, Event do |event|
        %w[send_to_publisher to_trash].include?(event.type) && event.entry.correcting?
      end

      can :update, Entry do |entry|
        entry.correcting?
      end
    end

    #################
    #   publisher   #
    #################

    if user.publisher?
      can :create, Event do |event|
        %w[publish return_to_corrector to_trash].include?(event.type) && event.entry.awaiting_publication?
      end

      can :create, Event do |event|
        %w[return_to_corrector to_trash].include?(event.type) && event.entry.published?
      end

      can :update, Entry do |entry|
        entry.published?
      end
    end

    #######################
    # corrector&publisher #
    #######################

    if user.corrector? && user.publisher?
      can :create, Event do |event|
        %w[immediately_publish].include?(event.type) && event.entry.initiator == user
      end

      can :create, Event do |event|
        %w[return_to_author].include?(event.type) && event.entry.awaiting_correction?
      end

      can :create, Event do |event|
        %w[publish].include?(event.type) && event.entry.correcting?
      end

      can :update, Entry do |entry|
        entry.awaiting_publication?
      end
    end
  end
end
