class Task < ActiveRecord::Base

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'
  default_scope order(:id)

  default_value_for :initiator do User.current end

  scope :kind, lambda {|kind| User.current.try "#{kind}_tasks" }


  state_machine :initial => :pending do

    before_transition :on => [:accept, :comlpete, :restore] do | task, transition |
      Ability.new.authorize!(transition.event, task)
    end

    state :pending
    state :fresh
    state :processing
    state :completed

    after_transition :on => :accept do | task, transition |
      task.update_attributes! :executor => User.current
    end

    after_transition :on => :complete do |task, transition|
      task.send(:switch_entry_to_next_state)
    end

    after_transition :on => :restore do |task, transition|
      task.send(:switch_entry_to_previous_state)
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
    event :suspend do
      transition :fresh => :pending
    end
    event :restore do
      transition :completed => :processing
    end
  end

  def next_task
  end

  protected

    def switch_entry_to_next_state
      entry.switch_to_next_state
      next_task.try :clear!
    end

    def switch_entry_to_previous_state
      entry.switch_to_previous_state
      next_task.try :suspend!
    end

end


# == Schema Information
#
# Table name: tasks
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#

