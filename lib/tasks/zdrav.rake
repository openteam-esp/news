require 'curl'
require 'nokogiri'
require 'progress_bar'
require 'uri'

def zdrav_url
  @zdrav_url ||= 'http://zdrav.tomsk.ru'
end

def user
  @user ||= User.find_by_email('mail@openteam.ru')
end

def resolve_tasks(entry)
  entry.tasks.each do |entry_task|
    entry_task.update_attribute :initiator, user
    entry_task.update_attribute :executor, user
    entry_task.update_attribute :state, 'completed'
  end
end

def upload_file(from, to)
  filename = from.split('/').last.gsub(/(\.\w+)_\d+\.\w+\z/, '\1').downcase

  tmpfile = Tempfile.new(filename)
  tmpfile.binmode

  c = Curl::Easy.new(from) do |curl|
    curl.on_body { |data| tmpfile.write(data) }
    curl.on_failure { |easy| puts "Failure link #{from}" }
  end
  c.perform

  c = Curl::Easy.new("#{Settings['storage.url']}/api/el_finder/v2#{to}?cmd=upload&target=r17306_Lw") do |curl|
    curl.headers['User-Agent'] = 'curl'
    curl.headers['Accept'] = 'application/json'
    curl.headers['CLIENT_IP'] = '127.0.0.1'
    curl.headers['X_FORWARDED_FOR'] = ''
    curl.headers['REMOTE_ADDR'] = ''
    curl.multipart_form_post = true
    curl.on_failure { |easy| puts '===> Storage is not available! <===' }
  end
  c.http_post(Curl::PostField.file('upload[]', tmpfile.path, filename))
  tmpfile.close
  tmpfile.unlink

  response = JSON.parse(c.body_str)
  case response.keys.first
  when 'added'
    response = response['added'].first['url']
  when 'error'
    response = URI.extract(response['error'], ['http', 'https']).first
  end

  response
end

def update_images(entry)
  %w[annotation body].each do |part|
    page = Nokogiri::HTML(entry.send(part))
    page.xpath("//img[contains(@src, 'ru.tomsk.zdrav')]").each do |node|
      link = "#{zdrav_url}#{node.attr('src')}".strip_html
      width = node.attr('width')
      height = node.attr('height')
      storage_response = upload_file(link, entry.vfs_path)
      storage_response.gsub!(/\/(\d+-\d+)\//, "/#{width}-#{height}/") if width.present? && height.present?
      node['src'] = storage_response
    end
    entry.update_attribute part, page.to_html
  end
end

def update_links(entry)
  %w[annotation body].each do |part|
    page = Nokogiri::HTML(entry.send(part))
    page.xpath("//a[contains(@href, 'ru.tomsk.zdrav')]").each do |node|
      link = "#{zdrav_url}#{node.attr('href')}".strip_html
      storage_response = upload_file(link, entry.vfs_path)
      node['href'] = storage_response
    end
    entry.update_attribute part, page.to_html
  end
end

namespace :zdrav do

  desc 'Parse entries from zdrav.tomsk.ru'
  task :parse_entries => :environment do

    entries_href = []
    puts 'Fetch entries urls'
    curl = Curl::Easy.perform("#{zdrav_url}/news/news/index.html")
    print '.'
    page = Nokogiri::HTML(curl.body_str)
    years = page.css('ul.years a').map{|link| link['href']}
    years.each do |year_href|
      curl = Curl::Easy.perform("#{zdrav_url}#{year_href}")
      print '.'
      page = Nokogiri::HTML(curl.body_str)
      monthes = page.css('ul.monthes a').map{|link| link['href']}
      monthes.each do |month_href|
        curl = Curl::Easy.perform("#{zdrav_url}#{month_href}")
        print '.'
        page = Nokogiri::HTML(curl.body_str)
        entries_href << page.css('ul.entries_list a').map{|link| link['href']}
        page.css('div.pagination a').map{|link| link['href']}.each do |paginate_href|
          curl = Curl::Easy.perform("#{zdrav_url}#{paginate_href}")
          print '.'
          page = Nokogiri::HTML(curl.body_str)
          entries_href << page.css('ul.entries_list a').map{|link| link['href']}
        end
      end
    end

    print "\n"
    puts "Found #{entries_href.flatten.count} entries"

    bar = ProgressBar.new(entries_href.flatten.count)

    entries_href.flatten.each do |entry_href|
      curl = Curl::Easy.perform("#{zdrav_url}#{entry_href}")
      page = Nokogiri::HTML(curl.body_str)
      since = Time.zone.parse(page.css('#center-side-full .datetime').text.squish)
      title = page.css('#center-side-full h2').text.gsub(/\A\d{2}\.\d{2}\.\d{4}\s+[-|–]/, '').squish
      page.css('#center-side-full .text').children.each { |node| node.unlink if node.to_html.squish.empty? }
      annotation = page.css('#center-side-full .text').children.first.unlink.to_html
      body = page.css('#center-side-full .text').inner_html.strip
      slug = NewsEntry.new(:title => title).send(:set_slug).gsub(/--\d+\z/, '')
      entry = Channel.find(130).entries.find_by_slug(slug)
      if body.blank?
        body = annotation
        annotation = ''
      end
      if entry.present?
        entry.set_current_user(user)
        entry.since = since
        entry.title = title
        entry.annotation = annotation
        entry.body = body
      else
        entry = NewsEntry.new(:since => since, :title => title, :annotation => annotation, :body => body)
        entry.set_current_user(user)
        entry.channels << Channel.find(130)
        entry.state = 'published'
      end
      unless entry.save
        puts "ERROR save entry #{zdrav_url}#{entry_href}: #{entry.errors.full_messages.join(', ')}"
      end
      resolve_tasks(entry)
      bar.increment!
    end

  end

  desc 'Update external links for entries zdrav.tomsk.ru'
  task :prepare_attachments => :environment do
    entries_with_external = Channel.find(130).entries.map do |entry|
      entry if entry.annotation.to_s.scan(/ru.tomsk.zdrav/).any? || entry.body.scan(/ru.tomsk.zdrav/).any?
    end.flatten.uniq.delete_if(&:blank?)
    puts 'Upload and update images sources and links href'
    bar = ProgressBar.new(entries_with_external.count)
    entries_with_external.each do |entry|
      update_images(entry)
      update_links(entry)
      bar.increment!
    end
  end

  desc 'Import entries zdrav.tomsk.ru'
  task :import => ['zdrav:parse_entries', 'zdrav:prepare_attachments'] do
  end

end
