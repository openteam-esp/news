class InterviewParser < Parser
  protected

  def fetch_news_body(news_url, news)
    body = super.gsub("<table>","<div class='answer'>").gsub(/<\/table>|<\/td>/,"</div>").gsub(/<tbody>|<\/tbody>|<tr>|<\/tr>/,"").gsub("<td>","<div>")
    update_image_links(body, news)
  end

  def update_image_links(news_body, news)
    page = Nokogiri::HTML(news_body)
    page.xpath("//img").each do |node|
      storage_response = upload_file(node.attr('src'), news.vfs_path)
      node['src'] = storage_response
    end

    page.css(".answer a").each do |node|
      storage_response = upload_file(node.attr('href'), news.vfs_path)
      node['href'] = storage_response
    end

    page.to_html
  end
end
