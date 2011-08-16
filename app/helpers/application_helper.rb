module ApplicationHelper
  def gilensize(text)
    text.clean.gilensize.html_safe
  end
end
