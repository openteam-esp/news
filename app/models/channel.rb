class Channel
  include Mongoid::Document

  field :title, :type => String

  has_many :recipients
  has_and_belongs_to_many :entries

  def published_entries
    entries.published.order_by([:updated_at, :desc])
  end
end
