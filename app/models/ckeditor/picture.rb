class Ckeditor::Picture < Ckeditor::Asset
  if Settings[:s3]
    has_attached_file :data,
                      :path => "pictures/:id/:style_:basename.:extension",
                      :storage => :s3,
                      :bucket => 'news-demo',
                      :s3_host_alias => "s3.openteam.ru/news-demo",
                      :url => ":s3_alias_url",
                      :s3_options => { :server => 's3.openteam.ru' },
                      :s3_credentials => Settings[:s3],
                      :styles => { :content => '800>', :thumb => '118x100#' }
  else
    has_attached_file :data,
                      :url  => "/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                      :path => ":rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                      :styles => { :content => '800>', :thumb => '118x100#' }
  end

  validates_attachment_size :data, :less_than => 2.megabytes
  validates_attachment_presence :data

  def url_content
    url(:content)
  end
end
