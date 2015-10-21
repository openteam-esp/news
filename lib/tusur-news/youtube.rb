class YoutubeParser < TusurNewsParser
  VideoInfo.provider_api_keys = { youtube: Settings[:youtube][:api_key] }
  attr_accessor :yt_channel, :channel, :user

  def initialize(from)
    @yt_channel = Yt::Channel.new id:  from
    @channel = Channel.where(title: yt_channel.title, entry_type: 'youtube_entry', description: yt_channel.description).first_or_create
    @user ||= User.find_by_email "mail@openteam.ru"
    @errors_counter = {}
    @success_counter = 0
  end


  def import
    pb = ProgressBar.new(videos.count)
    videos.each do |video|
      entry = YoutubeEntry.where(youtube_code: video.id ).first_or_create
      entry.body = description_spike( video.id )
      entry.body = "..." if entry.body.blank?
      entry.since = Time.zone.parse video.published_at.to_s
      entry.title = video.title
      entry.current_user  = user
      entry.state = "published"
      entry.channels << channel
      puts "#{entry.body} -  #{entry.youtube_code}"
      if entry.valid?
        entry.save
        resolve_tasks entry
        @success_counter += 1
      else
        @errors_counter[video.id] = entry.errors.messages
      end
      pb.increment!
    end
    puts "Возникло проблем: #{@errors_counter.length}: #{ @errors_counter.inspect }" if @errors_counter.any?
    puts "Успешно импортировано #{@success_counter} видео" if @success_counter > 0
  end


  private

  def videos
    yt_channel.videos
  end

  def description_spike(id)
    VideoInfo.new("https://youtu.be/" + id).description
  end

end
