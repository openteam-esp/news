
class YoutubeEntry < Entry
  # NOTE: используется для методов min_since_event_datetime и max_until_event_datetime в #EntrySearch
  CLEAN_KEYS = %w(annotation source source_link author images)
  attr_accessible :youtube_code
  validates_presence_of :youtube_code, :on => :update
  validate :available_video, :on => :update
  normalize_attribute :youtube_code do |code|
    code.match(URI.regexp) ? Yt::Video.new(url: code).id : code
  end

  def event_entry_properties
    []
  end

  def prefix
    "youtube_entry"
  end

  def is_youtube?
    true
  end

  def available_video
    begin
      Yt::Video.new(id: youtube_code).embeddable?
    rescue
      errors.add(:youtube_code, 'Неверная ссылка на видео (или видео закрыто для вставки на другие сайты)')
    end
  end

  def as_json(options = {})
    super.merge( youtube_code: youtube_code ).reject{|s| CLEAN_KEYS.include? s}
  end

end

# == Schema Information
#
# Table name: entries
#
#  id                   :integer          not null, primary key
#  deleted_at           :datetime
#  since                :datetime
#  deleted_by_id        :integer
#  initiator_id         :integer
#  legacy_id            :integer
#  author               :string(255)
#  slug                 :string(255)
#  state                :string(255)
#  vfs_path             :string(255)
#  annotation           :text
#  body                 :text
#  title                :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  source               :text
#  source_link          :string(255)
#  type                 :string(255)
#  actuality_expired_at :datetime
#

