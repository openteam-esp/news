class ReleasesParser < TusurNewsParser

  def parse
    years = 2007..Date.today.year
    pb = ProgressBar.new(years.count)
    years.each do |year|
      pb.increment!
      puts "importing #{year}"
      (0..page_quantity(releases_url_builder(year))).each do |page_number|
        paginated_url = "#{url}#{year}.html?page=#{page_number}"
        puts paginated_url
        fetch_entries(paginated_url)
      end
    end
    puts "Errors:"
    @error_counter.each do |key, value|
      puts key
      puts value
    end
    write_to("legacy_urls_releases.yml")
  end

  private

  def releases_url_builder(year)
    "#{url}#{year}.html "
  end
end
