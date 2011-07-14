class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # TODO: дописать для Entry
    can [:read, :create], Entry

    can :create, Event do |event|
      %w[send_to_corrector to_trash].include? event.type
    end

    if user.corrector?
      can :create, Event do |event|
        %w[correct send_to_publisher return_to_author to_trash].include? event.type
      end
    end

    if user.publisher?
      can :create, Event do |event|
        %w[publish return_to_corrector to_trash].include? event.type
      end
    end

  end
end
