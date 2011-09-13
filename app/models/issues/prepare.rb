class Prepare < Issue
  state_machine :initial => :processing do
    state :processing
    state :completed

    after_transition :to => :processing do |issue, transition|
      issue.send(:switch_entry_to_previous_state)
    end

    event :complete do
      transition :processing => :completed
    end

    event :restore do
      transition :completed => :processing
    end
  end
end
