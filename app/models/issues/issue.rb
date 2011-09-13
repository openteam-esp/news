class Issue < ActiveRecord::Base

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'
  default_scope order(:id)

  default_value_for :initiator do User.current end

  state_machine :initial => :pending do
    state :pending
    state :fresh
    state :processing
    state :completed

    after_transition :to => :completed do |issue, transition|
      issue.send(:switch_entry_to_next_state)
    end

    event :clear do
      transition :pending => :fresh
    end
    event :accept do
      transition :fresh => :processing
    end
    event :complete do
      transition :processing => :completed
    end
    event :cancel do
      transition :processing => :fresh
    end
  end

  protected

    def switch_entry_to_next_state
      entry.update_attribute :state, Entry.enums[:state][Entry.enums[:state].index(entry.state) + 1]
      entry.issues.with_states(:pending).first.try :clear!
    end
end

# == Schema Information
#
# Table name: issues
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#

