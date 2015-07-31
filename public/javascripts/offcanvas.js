$(document).ready(function () {
  $('[data-toggle="offcanvas"]').click(function () {
    $('.row-offcanvas').toggleClass('active')
  });

  var buttonsHref = $('[data-href]');

  buttonsHref.dblclick(function () {
    var element = $(this);
    var path = element.data('href');
    var title = element.data('title');

    window.history.pushState(null, title, path);
    window.location.replace(path);
  });

  var buttonsUpload = $('.upload-button');
  var hiddenClass = 'hidden';
  buttonsUpload.each(function(idx, element){
    var element = $(element);
    var btn = element.find('.upload-button-btn');
    var inpt = element.find('.upload-button-inpt');
    var content = element.find('.upload-button-content');
    var submitBtn = element.find('.upload-button-submit');

    btn.click(function(){
      inpt.trigger('click');
    });

    inpt.change(function(){
      var val = inpt.val();

      if(val){
        submitBtn.removeClass(hiddenClass);
      }else {
        submitBtn.addClass(hiddenClass);
      }

      content.text(val);
    });

  });
});
