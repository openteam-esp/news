class Prepare < Issue
  state_machine :initial => :processing do
    state :processing
    state :completed
    state :pending

    after_transition :to => :completed do |prepare, transition|
      prepare.entry.update_attribute(:state, :correcting)
    end

    event :complete do
      transition :processing => :completed
    end

    event :discard do
      transition :processing => :pending
    end

    event :restore do
      transition :pending => :processing
    end
  end
end
