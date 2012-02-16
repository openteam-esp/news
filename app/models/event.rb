# encoding: utf-8

include ActionView::Helpers::DateHelper

class Event < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :task

  default_scope :order => 'id DESC'

  before_create :save_and_serialize_entry

  scope :with_serialized_entry, where("serialized_entry is not null")

  def versioned_entry
    return unless serialized_entry?
    attributes = JSON.parse(serialized_entry).symbolize_keys
    if event_entry_properties = attributes.delete(:event_entry_properties)
      event_entry_properties.each{ |o| o.delete('id')}
      attributes[:event_entry_properties_attributes] = event_entry_properties
    end
    attributes.delete(:type).constantize.new(attributes)
  end

  private

    def save_and_serialize_entry
      self.serialized_entry = entry.to_json if event == 'complete'
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

