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

  def image_for(image, options)
    if thumbnail = image.create_thumbnail(options)
      content_tag :div, :class => 'entry_image' do
        image_tag_for(thumbnail) + "#{image.description if options[:title]}"
      end
    end
  end

  def rss_description(entry)
    description = entry.images.any? ? image_for(entry.images.first, :width => 100, :height => 100) : ''
    description += (entry.annotation || '').html_safe
    description += entry.body.html_safe
    description += content_tag :div do
      content = ''
      content += "Время и место проведения: "
      list = ''
      entry.event_entry_properties.each do |event|
        list += content_tag :div, event.interval
        list += content_tag :div, event.location
      end
      content += content_tag :ul, list.html_safe
      content.html_safe

    end if entry.is_a?(EventEntry)
    description
  end
end
