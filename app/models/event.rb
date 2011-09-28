# encoding: utf-8

include ActionView::Helpers::DateHelper

class Event < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :task

  default_scope :order => 'created_at DESC'

  before_create :save_and_serialize_entry

  default_value_for :user do User.current end

  def versioned_entry
    Entry.new.from_json(serialized_entry)
  end

  private

    def save_and_serialize_entry
      self.serialized_entry = entry.to_json(:methods => %w[asset_ids channel_ids]) if event == 'complete'
    end
end









# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  event            :string(255)
#  text             :text
#  entry_id         :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  serialized_entry :text
#  task_id          :integer
#

