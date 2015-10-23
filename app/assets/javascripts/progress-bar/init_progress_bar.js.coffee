$ ->
  if $(".js-job-id").length
    queryForPercentage()


queryForPercentage = () ->
  job_id = $('.js-job-id').data('id')
  console.log job_id
  console.log "query"
  $.ajax
    url: "/job_status"
    data:
      job_id: job_id
    success: (data) ->
      console.log "succcccccccessssss!"
      percentage = data['percent']
      $('.js-progress-bar-number').text("#{percentage}%")
      $('.js-progress-bar').animate(width: "#{percentage}%")
      console.log data

      if data['percent'] != 100
        console.log data["percent"]
        setTimeout(queryForPercentage, 500)
      if data["percent"] == 100
        $(".sync-status").text("Синхронизация завершена")
        $(".js-progress-bar").animate("background-color": "#105E28" )

      return
