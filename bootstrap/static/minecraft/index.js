/*if(!console) {
  var console = { log: function() {} };
}*/

// Functio nto calculate twitter 'since' date.
function calculateSince(datetime){
	"use strict";
    var tTime=new Date(datetime);
    var cTime=new Date();
    var sinceMin=Math.round((cTime-tTime)/60000);
    if(sinceMin==0) {
        var sinceSec=Math.round((cTime-tTime)/1000);
        if(sinceSec<10)
          var since='less than 10 seconds ago';
        else if(sinceSec<20)
          var since='less than 20 seconds ago';
        else
          var since='half a minute ago';
    } else if(sinceMin==1) {
        var sinceSec=Math.round((cTime-tTime)/1000);
        if(sinceSec==30)
          var since='half a minute ago';
        else if(sinceSec<60)
          var since='less than a minute ago';
        else
          var since='1 minute ago';
    } else if(sinceMin<45)
        var since=sinceMin+' minutes ago';
    else if(sinceMin>44&&sinceMin<60)
        var since='about 1 hour ago';
    else if(sinceMin<1440){
        var sinceHr=Math.round(sinceMin/60);
    if(sinceHr==1)
      var since='about 1 hour ago';
    else
      var since='about '+sinceHr+' hours ago';
    } else if(sinceMin>1439&&sinceMin<2880)
        var since='1 day ago';
    else {
        var sinceDay=Math.round(sinceMin/1440);
        var since=sinceDay+' days ago';
    }
    return since;
};

// Load the latest tweets
// Load the latest tweets
$(function(){
	"use strict";
    var username = 'sunsethosting';
    // https://api.twitter.com/1/statuses/user_timeline.json?screen_name=sunsethosting&count=2&callback=?
    var url='/dral/twitter/tweets.php';

    $.getJSON(url, function(json) {
        var show = new Array();
        $.each(json, function(i, tweet) {
            // process links and reply
            var newtweet = new Object();
            newtweet.text = tweet.text.replace(/(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig, function(url) {
                return '<a href="'+url+'">'+url+'</a>';
            }).replace(/B@([_a-z0-9]+)/ig, function(reply) {
                return  reply.charAt(0)+'<a href="http://twitter.com/'+reply.substring(1)+'">'+reply.substring(1)+'</a>';
            });
            
            newtweet.since = calculateSince(tweet.created_at);
            
            show.push(newtweet);
        });
            
        var tweetbar = $("#social > div");
        tweetbar.find("div:first").html(
          "<b>"+show[0].since+"</b><br />"
          +show[0].text
        )
        tweetbar.find("div:last").html(
          "<b>"+show[1].since+"</b><br />"
          +show[1].text
        )

    });
});

$(function() {
    "use strict";
    var badurls = [];
    
    $("[url]").each(function(badurl) {
        var $this = $(badurl);
        
        badurls.push(badurl);
        
        $this.attr('data-url', $this.attr('url'));
        $this.removeAttr('url');
    });
    console.log('bad urls: ', badurls);
    
	$("[data-url]").click(function(event) {
	    var newpage;
	    
	    if(event.which === 2) {
	        newpage = function(url) {
	            window.open(url, '_newtab');
	        };
	    } else {
	        newpage = function(url) {
	            window.location.href = url;
	        };
	    }
	
	    var $this = $(this);
		newpage($this.attr('data-url'));
	});
});

$(function() {
    $('.preload').removeClass('preload');
});

$(function() {
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-36749300-1']);
  _gaq.push(['_setDomainName', 'sunsethosting.co.uk']);
  _gaq.push(['_setAllowLinker', true]);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
});

$(function() {
  var scale = 2;
  keymage('shift-s', function() {
    if(scale === 2) {
      scale = 10
    } else {
      scale = 2;
    }
    alert('New speed is ' + 10/scale)
  });
  
  $(window).on('scroll', function(){   
    scrolled = $(window).scrollTop()
    var change = scrolled / scale; 
    $(".parallax").css('background-position', '0 '+change+'px');
  });
})// Add the slider with his packages
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
