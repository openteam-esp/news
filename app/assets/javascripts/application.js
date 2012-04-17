/* This is a manifest file that'll be compiled into including all the files listed below.
 * Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
 * be included in the compiled file accessible from http://example.com/assets/application.js
 * It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
 * the compiled file.
 *
 *= require jquery.js
 *= require jquery-ui.js
 *= require jquery_ujs.js
 *= require jquery.ui.datepicker.ru.js
 *= require jquery.ui.timepicker.js
 *= require jquery.ui.timepicker.ru.js
 *= require info_plugin.js
 *= require jquery_nested_form.js
 */

function preload_images(images) {
  $("<div />")
    .addClass("images_preload")
    .appendTo("body")
    .css({
      "position": "absolute",
      "bottom": 0,
      "left": 0,
      "visibility": "hidden",
      "z-index": -9999
    });
  $.each(images, function(index, value) {
    $("<img src='" + value + "' />").appendTo($(".images_preload"));
  });
};

function initialize_flash_block() {
  $('.flash_wrapper').slideDown('slow');
  $('.flash_wrapper .close_link').click(function(){
    $('.flash_wrapper').slideUp('slow');
  });
};

function initialize_datepicker() {
  if ($.fn.datepicker) {
    $("form.formtastic input.date_picker").datepicker({
      showOn: "button",
      buttonText: "выбрать",
      buttonImage: "/assets/jquery_ui/calendar.png",
      changeMonth: true,
      changeYear: true
    });
  };
  if ($.fn.datetimepicker) {
    $("form.formtastic input.datetime_picker").datetimepicker({
      showOn: "button",
      buttonText: "выбрать",
      buttonImage: "/assets/jquery_ui/calendar.png",
      changeMonth: true,
      changeYear: true,
      hourGrid: 4,
      minuteGrid: 10
    });
  };
};

function initialize_tipsy() {
  if ($.fn.tipsy) {
    $(".edit_form_actions_wrapper.top a[rel='tipsy']").tipsy({
      gravity: "s"
    });
    $(".edit_form_actions_wrapper.bottom a[rel='tipsy']").tipsy({
      gravity: "n"
    });
  };
};

function asset_upload() {
  if ($.fn.fileupload) {
    var upload_link = $("#file_upload_link");
    $("form.formtastic.asset #asset_file").fileupload({
      dataType: "html",
      start: function(e) {
        upload_link.addClass("ajax_loading");
      },
      stop: function(e) {
        upload_link.removeClass("ajax_loading");
      },
      add: function(e, data) {
        data.submit()
        .success(function (result, textStatus, jqXHR) {
          $("<div id='ajax_result'/>").hide().appendTo("body").html(result);
          $(".assets_with_form")
            .html($("#ajax_result .assets_with_form").html());
          $("#ajax_result").remove();
          asset_upload();
        })
        .error(function (jqXHR, textStatus, errorThrown) {
          upload_link.removeClass("ajax_loading");
          var response = jqXHR.responseText.replace(/<head>.*<\/head>/m, '');
          alert(errorThrown + "\n\n" + response);
        });
      }
    });
  };
  $(".side_stuff .assets_with_form .remove")
    .bind('ajax:before', function() {
      $(this).addClass("ajax_loading");
    })
    .bind('ajax:complete', function(xhr, status) {
      $(this).removeClass("ajax_loading");
    })
    .bind('ajax:success', function(xhr, data, status) {
      $("<div id='ajax_result'/>").hide().appendTo("body").html(data);
      $(".assets_with_form")
        .html($("#ajax_result .assets_with_form").html());
      $("#ajax_result").remove();
      asset_upload();
    })
    .bind('ajax:error', function(evt, jqXHR, status, errorThrown) {
      alert(errorThrown + "\n\n" + jqXHR.responseText);
    });
};

function tab_toggler(target_id){
  var target = '.'+target_id;
  var issues = $('.issues');
  var events = $('.events');
  if (issues.length > 0) {
    issues.add(events).hide();
    $('.side_stuff .tabs li').removeClass('active');
  };
  $('#'+target_id).parent().addClass('active');
  $(target).show();
};

function initialize_tabs(){
  tab_toggler($('.side_stuff .tabs li.active a').attr('id'));
  $(".side_stuff .tabs li a").click(function(){
    tab_toggler($(this).attr('id'));
  });
};

function adding_subtaks() {
  var add_link = $('.add_subtask');

  add_link.click(function(){
    var issue_id = $(this).attr('id').match(/\d+/);
    var subtasks_id = '#'+$(this).attr('id').match(/[a-zA-Z]+/);
    var actions_block = $(this).closest('.actions');

    $(subtasks_id).unbind();
    $('.cancel_link').die();

    if (!$(subtasks_id).find('form#new_subtask').length > 0) {
      actions_block.slideToggle('slow');
      add_link.parent().after('<img src="/assets/ajax_loading.gif" height="16" widht="16" style="margin-left: 152px; margin-top: 10px;"/>');

      $.ajax({
        url: '/manage/news/issues/'+issue_id+'/subtasks/new',
        success: function(data){
          add_link.parent().next('img').remove();
          $(data).hide().prependTo(subtasks_id).slideDown('slow');

          $('.cancel_link').live('click', function () {
            actions_block.slideToggle('slow');
            $(subtasks_id + ' form#new_subtask').slideUp('slow', function(){$(this).remove()});
          });
        }
      });

      $(subtasks_id)
        .bind('ajax:before', function(evt, xhr, settings){
          $(subtasks_id).find('form#new_subtask input[name="commit"]').attr('disabled', 'disabled').val('Добавление...');
        })
        .bind('ajax:success', function(evt, data){
          $(subtasks_id+" form#new_subtask").replaceWith(data);
          if (!$(subtasks_id).find('form#new_subtask').length > 0) {
            actions_block.slideToggle('slow');
          };
        });
    };
  });
};

function commit_form_entry() {
  $("#commit_form_entry").click(function() {
    $(".main_container .article form.entry").submit();
    return false;
  });
  $("#cancel_form_entry").click(function() {
    $(".side_stuff form.entry").submit();
    return false;
  });
};

function disabled_link(){
  $('a.disabled').live('click', function(){
    return false;
  });
};

function choose_file(){
  $('.choose_file').live('click', function(){
    var link = $(this);
    var attached_file_wrapper = link.closest('.fields');
    var origin_id = attached_file_wrapper.find('.image_url').attr('id');
    var input = $('#'+origin_id);

    var dialog = link.create_or_return_dialog('elfinder_picture_dialog');

    dialog.attr('id_data', origin_id);

    dialog.load_iframe();

    input.change(function(){
      var image_url = input.val();
      var file_name = decodeURIComponent(image_url).match(/([^\/.]+)(\.(.{3}))?$/);

      attached_file_wrapper
        .children('.image_wrapper')
        .html('<a href="'+image_url+'"><img src="'+image_url+'" width="150" ></a>');

      input.unbind('change');
    });

    return false;
  });
};

function delete_file(){
  $('.delete_file').live('click', function(){
      $('.attached_file .wrapper').html('<span>Файл не выбран</span>');
      $('#image_url').val('');

      return false;
    });
};

/* вызов функций после построения полной структуры документа */
$(function() {
  $("input.focus_first:first").focus();
  initialize_flash_block();
  initialize_datepicker();
  initialize_tipsy();
  initialize_tabs();
  disabled_link();
  adding_subtaks();
  asset_upload();
  commit_form_entry();
  preload_images([
    "/assets/ajax_loading.gif",
    "/assets/jquery_ui/calendar.png"
  ]);
  choose_file();
  delete_file();
  $('form').live('nested:fieldAdded', function() {
    initialize_datepicker();
  });
});
/*////*/
