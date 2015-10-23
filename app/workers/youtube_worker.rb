class YoutubeWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(youtube_channel_code)
    at 0
    parser = YoutubeParser.new(youtube_channel_code)
    quantity = parser.videos_quantity - 1
    parser.videos.each.with_index do |video, i|
      at index_to_percent(quantity, i)
      parser.import_video video
    end
  end

  private

  def index_to_percent(total, current)
    current*100/(total)
  end
end
