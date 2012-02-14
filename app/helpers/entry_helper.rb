# encoding: utf-8

module EntryHelper
  def empty_message(attribute)
    I18n.t("blank_entry_#{attribute}")
  end

  def presented(entry, attribute)
    entry.send(attribute).presence.try(:truncate, 80, :omission => '…') || empty_message(attribute)
  end

  def composed_title(entry)
    [ presented(entry, :title), entry.body.to_s.strip_html.presence].compact.join(' – ').truncate(100, :omission => '…')
  end

  def creator_of(entry)
    result = "Создано "
    result += I18n.l(entry.created_at, :format => :long)
    result += " ("
    result += time_ago_in_words(entry.created_at)
    result += " назад)"
  end

  def render_statistic(entry)
    result  = "Состояние: "
    result += ::I18n.t("entry.state.#{entry.state}")
    result += ". "
    result += creator_of(entry.events.first)
    result += ". "
    result += "Пользователь: "
    result += entry.events.first.user.name
    result += "."
    content_tag :span, result, :class => "entry_statistic"
  end

  def presented_header(entry)
    if entry.title.presence
      content_tag :h2, entry.title, :class => 'title'
    else
      content_tag :h2, empty_message(:title), :class => :empty
    end
  end

  def presented_html(entry, attribute)
    if entry.send(attribute).to_s.strip_html.presence
      content_tag :div, raw(entry.send(attribute))
    else
      content_tag :div, empty_message(attribute), :class => :empty
    end
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

  def image_for(entry, options)
    if entry.image_url?
      entry.resize_image(options)
      content_tag :div, image_tag(entry.resized_image_url, entry.resized_image_dimentions.merge(:alt => entry.image_description)), :class => 'entry_image'
    end
  end

end
