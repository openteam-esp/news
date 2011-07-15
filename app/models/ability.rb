class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :create], Entry

    can [:update, :destroy], Entry do |entry|
      entry.draft?
    end

    can :create, Event do |event|
      %w[send_to_corrector to_trash].include? event.type
    end

    if user.corrector?
      can :create, Event do |event|
        %w[correct send_to_publisher return_to_author to_trash].include? event.type
      end

      can :update, Entry do |entry|
        entry.correcting?
      end
    end

    if user.publisher?
      can [:create, :destroy], Event do |event|
        %w[publish return_to_corrector to_trash].include? event.type
      end

      can [:update, :destroy], Entry do |entry|
        entry.published?
      end
    end

  end
end
