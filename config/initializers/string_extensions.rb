class String
  def strip_html
    Sanitize.clean(self).squish
  end
end
