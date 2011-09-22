class String
  def sanitize
    Sanitize.clean(self, Sanitize::Config::RELAXED).squish
  end

  def strip_html
    Sanitize.clean(self).squish
  end

  def gilensize_text(options={})
    self.gilensize(options.merge!(:html => false, :raw_output => true)).strip_html
  end
end
