class SmiParser < TusurNewsParser
  def parse
    years = 2007..Date.today.year

    pb = ProgressBar.new(years.count)
    years.each do |year|
      pb.increment!
      puts "importing #{year}"
      (0..page_quantity(smi_url_builder(url, year))).each do |page_number|
        paginated_url = "#{@url}#{year}/index.html?page=#{page_number}"
        puts paginated_url
        fetch_entries(paginated_url)
      end
    end
    #puts "Errors:"
    #@error_counter.each do |key, value|
      #puts key
      #puts value
    #end
    #file = File.open("legacy_urls.yml", 'a+')
    #yml = YAML.load_stream file
    #hash = {}
    #yml.each{|h| hash[h.keys.first] = h.values.first}
    #@legacy_urls.each {|pair| file.write pair.to_yaml unless hash[pair.keys.first] }
    #file.close
  end


  def smi_url_builder(url, year)
  end
end
