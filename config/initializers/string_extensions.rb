class String
  def sanitize
    Sanitize.clean(self, Sanitize::Config::RELAXED).squish
  end

  def strip_html
    Sanitize.clean(self).squish
  end

  def gilensize_with_html(options={})
    if self.html_safe?
      self.gilensize_without_html(options).html_safe
    else
      self.gilensize_without_html(options.merge!(:html => false, :raw_output => true))
    end
  end

  alias_method_chain :gilensize, :html
end
