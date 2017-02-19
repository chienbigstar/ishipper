document.addEventListener("turbolinks:load", function() {
  $allow_reload_data = false;
  on_loading_after();
  on_reload_data();
  var flash = function slide_up_flash(){
    setTimeout(function(){
      $('#flash').slideUp(2000);
    }, 1500);
  };

  $(document).ready(flash);
  $(document).on('page:load', flash);
  $(document).on('page:change', flash);

  $(function typeloop(){
    $("#title-slide-letter").typed({
      strings: [I18n.t("home_page.we")],
      typeSpeed: 80,
      showCursor: false
    });
    setInterval(function(){
      $('#slide-letter').typed({
        strings: [I18n.t("home_page.make_it_awsome")],
        typeSpeed: 80,
        showCursor: false
      });
    }, 400);
  });

  $(window).scroll(function(){
    var scroll_top = $(window).scrollTop();
    if (scroll_top > 150) {
      $('.td-ishipper-benefit-col-left').addClass('animated bounceInLeft');
      $('.td-ishipper-benefit-col-right').addClass('animated bounceInRight');
    }
  });
});

function on_loading_after(){
  $(document).on('click', '.loading-after', show_loading_after);
}

function show_loading_after(){
  $('#id-lvc-loading-after').show();
}

function close_loading_after(){
  $('#id-lvc-loading-after').hide();
}

function on_reload_data(){
  $(document).on('click', '.reload-data', reload_data_by_request);
}

function order_reload_data(link){
  $('#area_hidden').append('<a data-remote="true" href="' + link + '"></a>');
}

function reload_data_by_request(){
  if($allow_reload_data)
    $('#area_hidden').children().trigger('click');
}

function reset_reload_data(){
  $allow_reload_data = false;
  $('#area_hidden').html('');
}

function clear_then_show_flash(data_flash){
  close_loading_after();
  $('#flash').html(data_flash);
  setTimeout(function(){
    $('#flash').show().slideUp(4000);
  }, 200);
}

function event_click_menu_main() {
  $(document).on('click', '.node-dropdown-status', function(){
    $url_current_list = $(this).attr('href');
    reset_invoice_variable();
    reset_shipper_variable();
  })
}

$(document).on('ready', function(){
  $('#area_hidden').append('<a data-remote="true" href="/realtime/new"></a>');
  $('#area_hidden').children().trigger('click');
  $('#area_hidden').html('');
});
