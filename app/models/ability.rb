class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:rss, :read, :create], Entry

    can :update, Entry do |entry|
      entry.draft?
    end

    can :destroy, Entry do |entry|
      entry.trash? && entry.initiator.id == user.id
    end

    can :create, Event do |event|
      %w[send_to_corrector to_trash].include? event.type if event.entry.initiator.id == user.id
    end

    if user.corrector?
      can :create, Event do |event|
        %w[to_trash].include? event.type if event.entry.awaiting_correction? || event.entry.draft?
      end

      can :create, Event do |event|
        %w[correct immediately_send_to_publisher return_to_author send_to_publisher].include? event.type
      end

      can :update, Entry do |entry|
        entry.correcting?
      end
    end

    if user.publisher?
      can :create, Event do |event|
        %w[to_trash].include? event.type if event.entry.awaiting_publication? || event.entry.draft? || event.entry.published?
      end

      can :create, Event do |event|
        %w[immediately_publish publish return_to_corrector].include? event.type
      end

      can [:update, :destroy], Entry do |entry|
        entry.published?
      end
    end

  end
end
