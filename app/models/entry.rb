class Entry
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps
  field :title,       :type => String
  field :annotation,  :type => String
  field :body,        :type => String
  field :since,       :type => DateTime
  field :until,       :type => DateTime
  field :state,       :type => String
  field :deleted,     :type => Boolean, :default => false

  has_and_belongs_to_many :channels
  has_many :events
  belongs_to :folder

  attr_accessor :user_id

  validates_presence_of :body

  after_create :create_event

  state_machine :initial => :draft do

    event :send_to_corrector do
      transition :draft => :awaiting_correction
    end

    event :correct do
      transition :awaiting_correction => :correcting
    end

    event :return_to_author do
      transition :awaiting_correction => :draft
    end

    event :send_to_publisher do
      transition :correcting => :awaiting_publication
    end

    event :publish do
      transition :awaiting_publication => :published
    end

    event :return_to_corrector do
      transition [:awaiting_publication, :published] => :awaiting_correction
    end
  end

  def title_or_body
    title.present? ? title.truncate(100) : body.truncate(100)
  end

  def self.folder(folder)
    return Entry.where(:deleted => true).group_by {|entry| I18n.l(entry.updated_at, :format => '%d %B %Y') } if folder == 'trash'
    states = folder == 'inbox' ? ['awaiting_correction', 'awaiting_publication'] : [folder]
    any_in(:state => states).where(:deleted => false).group_by {|entry| entry.state}
  end

  private
    def create_event
      events.create! :type => 'created', :user_id => user_id
    end
end
