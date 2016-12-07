document.addEventListener('turbolinks:load', function() {
  $('.td-fix-button-2').on('click', function (ev) {
    ev.preventDefault();
    $('#form_invoice_info').slideUp().modal('hide');
  });
    $position = $(window).scrollTop();
    $(window).scroll(function(){
      $current_position = $(window).scrollTop();
      $offset = $current_position - $position;
      $('.after_map').css('margin-top', '+=' + $offset/3);
      $('.zoom').css('margin-top', '+=' + $offset/10);
      $('.bt-next').css('margin-top', '+=' + $offset/5);
      $position = $current_position;
    });
});
