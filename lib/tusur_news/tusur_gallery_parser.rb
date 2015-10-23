class TusurGalleryParser < TusurNewsParser

  def parse
    index = Nokogiri::HTML(open url).css("#center-side-full p").flat_map{|p| p.css("a") }
    pb = ProgressBar.new(index.length)
    index.each do |a|
      gallery_url =  url_begin + a["href"]
      title = a.text.squish
      entry = NewsEntry.new(title: title, body: "<div class='hidden body'><h3>#{title}</h3></div>")
      if new_entry?(entry) && entry.title.present?
        parsed_entry = parse_entry(gallery_url, entry)
        entry.since = parsed_entry[:since]
        gallery = parsed_entry[:gallery]
        entry.set_current_user(user)
        entry.channels << channel
        entry.state = "published"
        entry.save

        raise entry.errors.inspect if entry.errors.any?
        @legacy_urls << {"'#{gallery_url}'" => "'#{entry.slug}'"}
        resolve_tasks(entry)
        fetch_gallery_images(gallery, entry)
      end
      pb.increment!
    end
    puts "Errors:"
    @error_counter.each do |key, value|
      puts key
      puts value
    end
    write_to("legacy_urls_gallerys.yml")
  end



  private

  def new_entry?(entry)
    channel.entries.where(title: entry.title).empty?
  end


  def parse_entry(link, entry)
    regex = /_\d*[.]jpg$/
    page = Nokogiri::HTML(open link).css(".element")
    time = Time.zone.parse page.at_css(".updated_at").text

    images = page.css("table img").collect do |img|
      img["src"].gsub!(regex, '')
      img
    end
    return {since: time, gallery:images}
  end
end
