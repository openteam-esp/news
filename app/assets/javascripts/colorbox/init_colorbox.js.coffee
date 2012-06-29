@init_colorbox = ->
  $(".main_container .article .entry_image img").each (index, element) ->
    original_img = $(element).attr("src").replace(/\d+-\d+\//, "")
    $(element).wrap("<a class='colorbox' href='#{original_img}' rel='gallery' />")
  $(".main_container .article .colorbox").colorbox
    "current": "{current} / {total}"
    "maxHeight": "85%"
    "maxWidth": "90%"
    "opacity": "0.3"
