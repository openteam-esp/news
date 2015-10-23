class YoutubeParser < TusurNewsParser
  VideoInfo.provider_api_keys = { youtube: Settings[:youtube][:api_key] }
  attr_accessor :yt_channel, :channel, :user
  Yt.configure do |config|
      config.log_level = :debug
  end

  def initialize(from)
    @yt_channel = Yt::Channel.new id:  from
    @channel = Channel.where(channel_code: yt_channel.id).first_or_create
    @user ||= User.find_by_email "mail@openteam.ru"
    @errors_counter = {}
    @success_counter = 0
  end


  def import
    puts channel.inspect
    pb = ProgressBar.new(videos_quantity)
    videos.each do |video|
      import_video video
      pb.increment!
    end
    puts "Возникло проблем: #{@errors_counter.length}: #{ @errors_counter.inspect }" if @errors_counter.any?
    puts "Успешно импортировано #{@success_counter} видео" if @success_counter > 0
  end

  def videos_quantity
    videos.count
  end

  def import_video(video)
    entry = channel.entries.where(youtube_code: video.id, type: YoutubeEntry).first_or_create
    if entry.new_record?
      entry.body ||= description_spike( video.id )
      entry.body = "..." if entry.body.blank?
      entry.since ||= Time.zone.parse video.published_at.to_s
      entry.title ||= video.title
    end
    entry.state = "published"
    entry.channels << channel
    entry.current_user  ||= user
    if entry.valid?
      entry.save
      resolve_tasks entry
      @success_counter += 1
    else
      @errors_counter[video.id] = entry.errors.messages
    end
  end



  def videos
    yt_channel.videos
  end

  def description_spike(id)
    VideoInfo.new("https://youtu.be/" + id).description
  end

end
