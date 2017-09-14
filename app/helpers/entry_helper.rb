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
    if entry.send(attribute).presence
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
    description = description || ''
    unless entry.annotation.blank?
      description += content_tag(:p, content_tag(:em, entry.annotation.gsub(/\<\/?p>/, '').gsub(/\<\/?em>/, '').html_safe))
    end
    description += entry.body.to_s.html_safe
    description += content_tag :div do
      content = ''
      entry.event_entry_properties.each do |event|
        content += content_tag :h4, "Дата и время проведения"
        content += content_tag :p, interval_for(event)
        content += content_tag :h4, "Место проведения" unless event.location.blank?
        content += content_tag :p, event.location unless event.location.blank?
      end
      content.html_safe
    end if entry.is_a?(EventEntry)
    description
  end

  def interval_for(event)
    since_date, since_time = l(event.since.to_datetime, :format => '%d.%B.%Y %H:%M').split(' ')
    until_date, until_time = l(event.until.to_datetime, :format => '%d.%B.%Y %H:%M').split(' ')

    since_date.gsub!(".", " ")
    since_date.gsub!(" #{Date.today.year}", "")
    until_date.gsub!('.', ' ')
    until_date.gsub!(" #{Date.today.year}", "")

    since_arr = []
    until_arr = []

    since_arr << content_tag(:span, since_date, :class => 'nobr')
    until_arr << content_tag(:span, until_date, :class => 'nobr') if since_date != until_date


    if since_time != '00:00'
      since_arr << ", #{since_time}"
      if until_time != '00:00' && until_time != '23:59'
        if since_time != until_time
          if until_arr.empty?
            until_arr << until_time
          else
            until_arr << ", #{until_time}"
          end
        else
          unless until_arr.empty?
            until_arr << ", #{until_time}"
          end
        end
      end
    else
      if until_time != '00:00' && until_time != '23:59'
        unless until_arr.empty?
          until_arr << ", #{until_time}"
        end
      end
    end

    res = since_arr.join

    unless until_arr.empty?
      res += ' &mdash; '
      res += until_arr.join
    end

    res.html_safe

  end

  def youtube_embed_for(id)
    Yt::Video.new( id: id).embed_html.html_safe rescue content_tag(:p, 'Ошибка генерации видео!', class: :warning)
  end

  def small_youtube_thumbnail(id)
    image_tag Yt::Video.new( id: id).thumbnail_url rescue content_tag(:p, 'Ошибка генерации превью для видео!', class: :warning)
  end
end
