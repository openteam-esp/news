class Event < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user

  validate :ready_to_send_to_publisher, :if => lambda { |e| %w[immediately_send_to_publisher send_to_publisher].include? e.kind }
  validate :ready_publish, :if => lambda { |e| %w[immediately_publish publish].include? e.kind }

  after_create :fire_entry_event

  def ready_to_send_to_publisher
    errors.add(:entry_title, ::I18n.t('Entry title can\'t be blank'))           if entry.title.blank?
    errors.add(:entry_annotation, ::I18n.t('Entry annotation can\'t be blank')) if entry.annotation.blank?
    errors.add(:entry_body, ::I18n.t('Entry body  can\'t be blank'))            if entry.body.blank?
  end

  def ready_publish
    ready_to_send_to_publisher
    errors.add(:entry_channels, ::I18n.t('Entry must have at least one channel')) if entry.channels.empty?
  end

  private
    def fire_entry_event
      entry.fire_events kind.to_sym unless %w[created updated].include?(kind)
    end
end

# == Schema Information
#
# Table name: events
#
#  id         :integer         not null, primary key
#  type       :string(255)
#  text       :text
#  entry_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

