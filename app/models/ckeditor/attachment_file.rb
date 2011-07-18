class Ckeditor::AttachmentFile < Ckeditor::Asset
  if Settings[:s3]
    has_mongoid_attached_file :data,
                              :path => "attachments/:id/:filename",
                              :storage => :s3,
                              :bucket => 'news-demo',
                              :s3_host_alias => "s3.openteam.ru/news-demo",
                              :url => ":s3_alias_url",
                              :s3_options => { :server => 's3.openteam.ru' },
                              :s3_credentials => Settings[:s3]
  else
    has_mongoid_attached_file :data,
                              :url => "/ckeditor_assets/attachments/:id/:filename",
                              :path => ":rails_root/public/ckeditor_assets/attachments/:id/:filename"
  end

  validates_attachment_size :data, :less_than => 100.megabytes
  validates_attachment_presence :data

  def url_thumb
    @url_thumb ||= begin
                     extname = File.extname(filename).gsub(/^\./, '')
                     "/javascripts/ckeditor/filebrowser/images/thumbs/#{extname}.gif"
                   end
  end
end
