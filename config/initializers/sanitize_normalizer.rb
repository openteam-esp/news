AttributeNormalizer.configure do |config|

  SANITIZE_CONFIG  = Sanitize::Config::RELAXED
  SANITIZE_CONFIG[:elements] += %w[audio video source div hr object param embed iframe]
  SANITIZE_CONFIG[:attributes]['a'] << 'target'
  SANITIZE_CONFIG[:attributes]['audio'] = %w[controls src]
  SANITIZE_CONFIG[:attributes]['video'] = %w[controls src poster width height]
  SANITIZE_CONFIG[:attributes]['source'] = %w[src type]
  SANITIZE_CONFIG[:attributes]['object'] = %w[width height]
  SANITIZE_CONFIG[:attributes]['param'] = %w[name value]
  SANITIZE_CONFIG[:attributes]['embed'] = %w[src type width height allowscriptaccess allowfullscreen]
  SANITIZE_CONFIG[:attributes]['iframe'] = %w[src width height allowfullscreen frameborder]
  SANITIZE_CONFIG[:attributes][:all] += %w[style class id]
  SANITIZE_CONFIG[:output] = :xhtml

  config.normalizers[:sanitize] = ->(value, options) do
    Sanitize.clean(value.to_s.gsub(/(\r|&#13;)/, ''), SANITIZE_CONFIG).gsub(%r{<a(.*?)>\n<img(.*?) />\n</a>}, '<a\1><img\2 /></a>')
  end
end
