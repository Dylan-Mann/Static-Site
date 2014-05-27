// Add the slider with his packages
$(function () {
  var currentValue = $('#currentValue'),
      packages = $(".package"),
      lastValue = 2,
      hasFaded = false,
      package_selection = $("#slider").slider({
        min: 0,
        max: 100,
        animate: true,
        value: 50,

        slide: function (event, ui) {
          var nearest = Math.round(ui.value / 100 * (packages.length-1)),
              spackage = $(packages[nearest]);

          if (nearest !== lastValue) {
            var fadetime = 125;
            currentValue.fadeOut(fadetime, function() {
              currentValue
                .text(spackage.find(".ram > b").text())
                .fadeIn(fadetime);
            });
            
            $(packages[lastValue]).hide();
            spackage.show();
          }
          lastValue = nearest;
        }
      });

  // Make the 2GB div visible at the start
  $(packages[2]).show();    
  $("#container #trial").click(function () {
      window.location.href = "/package/trial";
  });
});

$(function () {
    'use strict';

    var $slider = $('.royalSlider');
    $slider.royalSlider({
        arrowsNav: true,
        loop: true,
        keyboardNavEnabled: true,
        controlsInside: false,
        imageScaleMode: 'fill',
        arrowsNavAutoHide: false,
        //autoScaleSlider: true,
        slidesSpacing: 1,

        arrowsNavHideOnTouch: true,
        //autoScaleSliderWidth: 1010,
        //autoScaleSliderHeight: 568,
        controlNavigation: 'bullets',
        navigateByClick: true,
        transitionType: 'move',

        autoPlay: {
            enabled: true,
            stopAtAction: false,
            pauseOnHover: true,
            delay: 7000
        },

        block: {
            // animated blocks options go gere
            fadeEffect: true,
            moveEffect: 'none',
            moveOffset: 0,
            delay: 0
        }
    });
});
