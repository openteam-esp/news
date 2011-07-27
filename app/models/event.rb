class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, :type => String
  field :text, :type => String
  index :updated_at

  embedded_in :entry

  belongs_to :user

  validate :ready_to_send_to_publisher, :if => lambda { |e| %w[immediately_send_to_publisher send_to_publisher].include? e.type }
  validate :ready_publish, :if => lambda { |e| %w[immediately_publish publish].include? e.type }

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
      entry.fire_events type.to_sym if type != 'created' && type != 'updated'
    end
end
