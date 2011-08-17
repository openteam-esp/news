module ApplicationHelper
  def gilensize(text, options={})
    text = text.sanitize.html_safe if options[:html]
    text.gilensize
  end

  def presented_content_tag(tag, object, attribute, options={})
    css_classes = [attribute]
    css_classes << "empty" unless object.presented?(attribute, options)
    content_tag tag, gilensize(object.presented(attribute, options), options), :class => css_classes.join(' ')
  end

  def render_attribute_values(object, *attributes)
    content = "".html_safe
    attributes.flatten.each do | attribute |
      if object.send(attribute).any?
        section = content_tag(:h2, object.class.human_attribute_name(attribute))
        section += content_tag :ul do
          object.send(attribute).each do | value |
            concat(content_tag(:li, render(:partial => value)))
          end
        end
        content += content_tag :div, section, :class => attribute.to_s
      end
    end
    content
  end

end
