$ ->
  if $("#channel_entry_type").length
    console.log  "hola!"
    channel_code_visibility()

channel_code_visibility =  ->
  if $("#channel_entry_type").val() == "youtube_entry"
    $(" #channel_channel_code_input").show(500)
  $("#channel_entry_type").change ->
    if this.value == "youtube_entry"
     $(" #channel_channel_code_input").show(500)
    else
     $(" #channel_channel_code_input").hide(500)
