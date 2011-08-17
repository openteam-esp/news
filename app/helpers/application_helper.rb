module ApplicationHelper
  def gilensize(text, options={})
    text = text.sanitize.html_safe if options[:html]
    text.gilensize
  end

  def presented_content_tag(tag, object, attribute, options={})
    css_classes = [attribute]
    css_classes << "empty" unless object.presented?(attribute, options)
    content_tag tag, gilensize(object.presented(attribute), options), :class => css_classes.join(' ')
  end
end
