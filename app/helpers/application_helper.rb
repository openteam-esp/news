# encoding: utf-8

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

  def render_statistic(entry)
    result  = "Состояние: "
    result += ::I18n.t("entry.state.#{entry.state}")
    result += ". "
    if entry.events.first
      result += entry.events.first.created_human
    else
      result += entry.created_human
    end
    result += ". "
    result += "Пользователь: "
    if entry.events.first
      result += entry.events.first.user.name
    else
      result += entry.initiator.name
    end
    result += "."
    content_tag :span, result, :class => "entry_statistic"
  end

  def resized_image_tag(image)
    width = 100
    if image.file_width > width
      ratio = width / image.file_width.to_f
      height = (image.file_height * ratio).to_i
    else
      width = image.file_width
      height = image.file_height
    end
    image_tag image_path(image, width, height, image.file_name), :alt => "", :size => "#{width}x#{height}"
  end
end

