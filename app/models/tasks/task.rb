class Task < ActiveRecord::Base

  belongs_to :entry
  belongs_to :initiator, :class_name => 'User'
  belongs_to :executor, :class_name => 'User'


  scope :kind, lambda {|kind| User.current.try "#{kind}_tasks" }
  scope :ordered, order('id desc')
  scope :not_deleted, where(:deleted_at => nil)
  scope :processing, where(:state => :processing)

  default_scope not_deleted.ordered

  def deleted?
    deleted_at
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

