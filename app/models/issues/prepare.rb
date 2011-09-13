class Prepare < Issue
  state_machine :initial => :processing do
    state :processing
    state :completed

    event :complete do
      transition :processing => :completed
    end

    event :restore do
      transition :completed => :processing
    end
  end
end
