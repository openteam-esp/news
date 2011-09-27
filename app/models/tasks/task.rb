class Task < ActiveRecord::Base

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'


  scope :kind, lambda {|kind| User.current.try "#{kind}_tasks" }
  scope :ordered, order('id desc')
  scope :not_deleted, where(:deleted_at => nil)
  scope :processing, where(:state => :processing)

  default_scope not_deleted.ordered

  delegate :prepare, :review, :publish, :to => :entry

  def deleted?
    deleted_at
  end

  def self.human_state_events
    [:accept, :complete, :restore, :refuse]
  end

  protected

    def authorize_transition(transition)
      Ability.new.authorize!(transition.event, self) if self.class.human_state_events.include? transition.event
    end

    def create_event(transition)
      entry.events.create! :entry => entry, :task => self, :event => transition.event.to_s if self.class.human_state_events.include? transition.event
    end

    def after_complete
      entry.up!
      next_task.try :clear!
    end

    def after_accept
      update_attributes! :executor => User.current
    end

    def after_restore
      entry.down!
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
#  issue_id     :integer
#  description  :text
#  deleted_at   :datetime
#

