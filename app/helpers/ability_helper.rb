module AbilityHelper

  def ability_to(action, subject)
    can?(action, subject) ? "enabled": "disabled"
  end

end
