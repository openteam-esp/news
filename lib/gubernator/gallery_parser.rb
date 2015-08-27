require 'yaml'

class GalleryParser < Parser
  def parse
    pb = ProgressBar.new(gallery_pages.count)
    gallery_pages.each do |page|
      fetch_entries(page)
      pb.increment!
    end
  end

  protected
  def fetch_entries(gallery_list_url)
    entries = YAML.load(open(gallery_list_url).read)
    entries['items'].each do |entry|
      gallery_url = "http://gubernator.tomsk.ru/photo?album=#{entry['id']}&type=images"
      create_gallery(gallery_url)
    end
  end

  def create_gallery(gallery_url)
    gallery = YAML.load(open(gallery_url).read)
    news = NewsEntry.new(:title => gallery['album'], :body => gallery['album'], :since => Time.zone.parse(gallery['datetime']))
    news.set_current_user(user)
    news.channels << channel
    news.state = "published"
    news.save

    resolve_tasks(news)
    fetch_gallery_images(gallery['items'], news)
  end

  def fetch_gallery_images(gallery_items, news)
    gallery_items.each do |item|
      storage_url = upload_file(item['big'], news.vfs_path)
      news.images.create(:url => storage_url , :description => item['title'])
    end
  end

  def gallery_pages
    year_links = (2012 ..2014).map{ |year| "http://gubernator.tomsk.ru/photo-#{year}?album=0&type=albums" }
    year_links << "http://gubernator.tomsk.ru/photo?album=0&type=albums"
  end
end
