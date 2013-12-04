$.fn.bindArticleSlideshow = function(slides) {

  var $this = $(this);

  var
  currentPhoto     = 0,
  duration         = 5000,
  transitionSpeed  = 500,
  easingMethod     = "easeOutQuart",

  intervalPID      = null,

  options          = null,
  $bullets         = $this.find(".bullets"),
  $data            = $this.find(".data"),
  $photos          = $this.find('.photos'),
  num_of_photos    = slides.length;

  function init()  {

    $title       = $data.append("<h2 />");
    $description = $data.append("<p />");
    $link        = $data.append('<a href="#" class="read_more">Read more</a>');

    $title       = $data.find("h2");
    $description = $data.find("p");
    $link        = $data.find('a');

    loadContent();

    setupPhotos();
    addBullets();
    bindBullets();

    options = $this.attr("data-options");

    if (options == "autoplay") play();
  }

  function loadContent() {

    if (slides[currentPhoto]) {
      $data.fadeOut(150, function() {

        $title.html(slides[currentPhoto].title);
        $description.html(slides[currentPhoto].description);
        $link.attr("href", slides[currentPhoto].url);

        $data.fadeIn(150);

      });
    }

  }

  function play() {
    intervalPID = setInterval(next, duration);
  }

  function stop() {
    clearInterval(intervalPID);
  }

  function next() {

    currentPhoto++;

    if (currentPhoto >= num_of_photos) {
      currentPhoto = 0;
    }

    selectBullet(currentPhoto);
    gotoPhoto(currentPhoto);

  }

  function setupPhotos() {
    for (var i = 0; i <= num_of_photos - 1; i++) {
      var $photo = $("<li><img /></li>");
      $photo.find("img").attr("src", slides[i].src);
      if (i == 0) $photo.addClass("selected");
      $photos.append($photo);
      $photo.attr("id", "photo_" + i);
    }
  }

  function bindBullets() {
    $bullets.find("a").on("click", onClick);
  }

  function onClick(e) {
    var $e    = $(e.target);
    var index = $e.parent().index();

    currentPhoto = index;

    stop();

    selectBullet(index);
    gotoPhoto(index);
  }

  function selectBullet(index) {
    $bullets.find("li").removeClass("selected");
    $bullets.find("li:nth-child(" + (index + 1) + ")").addClass("selected");
  }

  function gotoPhoto(index) {

    var $selectedPhoto = $photos.find("li.selected");
    var $clickedPhoto  = $photos.find("li:nth-child(" + (index + 1) + ")");

    if ( $selectedPhoto.attr("id") != $clickedPhoto.attr("id") ) {
      $selectedPhoto.fadeOut(250, function() {
        $(this).removeClass("selected");
      });

      loadContent();

      $clickedPhoto.fadeIn(250, function() {
        $(this).addClass("selected");
      });
    }
  }

  function addBullets() {

    for (var i = 0; i < num_of_photos; i++) {
      if (i == 0) {
        $bullets.append('<li class="selected"><a href="#"></a></li>');
      } else {
        $bullets.append('<li><a href="#"></a></li>');
      }

    }

  }

function updateSlideshow(data) {

  if (data.title) {
    $this.find(".title").fadeOut(150, function() {
      $this.find(".title").html(data.title);
      $this.find(".title").fadeIn(150);
    });

    var key = data.usageKey;

    if (key) {
      var url = $this.find(".source").attr("data-baseurl") + key;
      $this.find(".source").attr("href", url);
    }

  }
}

function onSuccess(data) {

  var images = data.results;

  var $photos = $slideshow.find(".photos");

  num_of_photos = images.length;

  $photos.css("width", num_of_photos * photoWidth);

  if (num_of_photos == 1) {
    $this.find(".controller").hide();
  }

  var n = 0;

  _.each(images, function(result) {

    n++;

    $photos.append("<li><div class='spinner'/></div><img id='photo_"+n+"'src='" + result.image + "' /></li>");

    var $img = $photos.find("#photo_" + n);

    slideData.push(result);

    $img.on("load", function() {

      var
      $li      = $img.parent();
      liWidth  = parseInt($(this).parent().css("width"), 10),
      liHeight = parseInt($(this).parent().css("height"), 10),
      h        = parseInt($(this).css("height"), 10),
      w        = parseInt($(this).css("width"), 10);

      $li.find(".spinner").fadeOut(100, function() { $(this).remove(); });

      $img.css("top", liHeight/2 - h/2 );
      $img.css("left", liWidth/2 - w/2 );
      $img.fadeIn(250);

    });
  });
}


init();

};


/*
* GOD sees everything
*/
var GOD = (function() {
  var subscribers = {};
  var debug = false;

  function unsubscribe(event) {
    delete subscribers[event];
  }

  function subscribe(event) {
    subscribers[event] = event
  }

  function _signal(event) {
    $(window).trigger(event);
    unsubscribe(event);
  }

  function _signalAll() {
    if (!_.isEmpty(subscribers)) {
      _.each(subscribers, _signal);
    }
  }

  // send signal to all the other subscribers
  function broadcast(protectedEvent) {
    _.each(subscribers, function(event) {
      protectedEvent != event && _signal(event);
    });
  }

  $(function() {
    $(document).keyup(function(e) {
      e.keyCode == 27 && _signalAll();
    });

    $('html').click(_signalAll);
  });

  return {
    subscribe: subscribe,
    unsubscribe: unsubscribe,
    broadcast: broadcast
  };
})();


/*
* ============
* SOURCE POPOVER
* ============
*/


(function($, window, document) {

  var ie6 = false;

  // Help prevent flashes of unstyled content
  if ($.browser.msie && $.browser.version.substr(0, 1) < 7) {
    ie6 = true;
  } else {
    document.documentElement.className = document.documentElement.className + ' ps_fouc';
  }

  var // Public methods exposed to $.fn.sourcePopoversourcePopover()
  methods = {}, // HTML template for the dropdowns
  templates = {
    main: [
      '<div id="<%= name %>_<%= id %>" class="yellow_popover"><div class="t"></div><div class="c"><h3><%= title %></h3><%= message %><BR/><%= remarks %></div><div class="b"></div></div>'
      ].join('')
  }, store = "sourcepopover", // Some nice default values
  defaults = {
    title: "Source"
  };

  // Called by using $('foo').sourcePopover();
  methods.init = function(settings) {
    settings = $.extend({}, defaults, settings);

    return this.each(function() {
      var // The current element
      $this = $(this), // We store lots of great stuff using jQuery data
      data  = $this.data(store) || {}, // This gets applied to the 'ps_container' element
      id    = $this.attr('id')  || $this.attr('name'), // This gets updated to be equal to the longest <option> element
      width = settings.width    || $this.outerWidth(), // The completed ps_container element
      $ps   = false;

      // Dont do anything if we've already setup sourcePopover on this element
      if (data.id) {
        return $this;
      } else {
        data.id        = id;
        data.$this     = $this;
        data.name      = store;
        data.templates = templates;
        data.title     = settings.title;
        data.message   = settings.message;
        data.remarks   = settings.remarks;
        data.settings  = settings;
      }

      // Hide the <select> list and place our new one in front of it
      $this.before($ps);

      // Save the updated $ps reference into our data object
      data.$ps = $ps;

      // Save the sourcePopover data onto the <this> element
      $this.data(store, data);

      $(this).click(_toggle);

      $(window).bind('resize.yellow_popover', function() {
        _refresh($this, data.name, data.id);
      });

      $(window).bind('_close.' + data.name + '.' + data.id, function() {
        var $ps = $("#" + data.name + "_" + data.id);
        _close($this, $ps);
      });

    });
  };

  // Build popover
  function _build(data) {
    var $ps = $(_.template(data.templates.main,
    {name:data.name, id:data.id, title: data.title, message:data.message, remarks:data.remarks}));

    $ps.bind('click', function(e) {
      e.stopPropagation();
    });

    return $ps;
  }

  // Close popover
  function _close($this, $ps) {
    var data = $this.data(store);
    GOD.unsubscribe("_close." + data.name + "." + data.id);

    if (is_ie) {
      $ps.hide();
      $ps.remove();
    } else {
      $ps.animate({top:$ps.position().top - 10, opacity:0}, 100, function() {
        $ps.remove();
      });
    }
  }

  // Refresh popover
  function _refresh($this, name, id) {
    var $ps = $("#" + name + "_" + id);
    if ($("#" + name + "_" + id).length != 0) {
      var x = $this.offset().left;
      var y = $this.offset().top;
      var w = $ps.width();
      var h = $ps.height();

      if (oldIE) {
        $ps.css("top", y - h);
      } else {
        $ps.css("top", y - h);
      }

      $ps.css("left", x - w / 2 + 7);
    }
  }

  // Open a popover
  function _toggle(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var data = $this.data(store);

    if ($("#" + data.name + "_" + data.id).length != 0) {
      var $ps = $("#" + data.name + "_" + data.id);
      _close($this, $ps);
    } else {
      data.$ps = _build(data);
      var $ps = data.$ps;

      // setup the close event & signal the other subscribers
      var event = "_close." + data.name + "." + data.id;
      GOD.subscribe(event);
      GOD.broadcast(event);

      $("#content").prepend($ps);
      _center($this, $ps);

      if (oldIE) {
        $ps.show();
      } else {
        $ps.animate({top:$ps.position().top + 10, opacity:1}, 100);
      }
    }
  }

  function _center($this, $ps) {
    // link coordinates
    var x = $this.offset().left;
    var y = $this.offset().top;

    // link dimensions
    var lw = $this.width();
    var lh = $this.height();

    // popover dimensions
    var w = $ps.width();
    var h = $ps.height();

    $ps.css("left", x - w / 2 + lw / 2);

    if (oldIE) {
      $ps.css("top", y - h - 5);
    } else {
      $ps.css("top", y - h - 10);
    }
  }

  // Expose the plugin
  $.fn.sourcePopover = function(method) {
    if (!ie6) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      }
    }
  };

})(jQuery, window, document);

/*
* ===============
* PROCESS POPOVER
* ===============
*/

(function($, window, document) {

  var ie6 = false;

  // Help prevent flashes of unstyled content
  if ($.browser.msie && $.browser.version.substr(0, 1) < 7) {
    ie6 = true;
  } else {
    document.documentElement.className = document.documentElement.className + ' ps_fouc';
  }

  var // Public methods exposed to $.fn.processPopover()
  methods = {}, // HTML template for the dropdowns
  templates = {
    main: [
      '<div id="<%= name %>_<%= id %>" class="yellow_popover"><div class="t"></div><div class="c"><h3><%= title %></h3><%= message %></div><div class="b"></div></div>'
      ].join('')
  }, store = "processpopover", // Some nice default values
  defaults = {
  };

  // Called by using $('foo').processPopover();
  methods.init = function(settings) {
    settings = $.extend({}, defaults, settings);

    return this.each(function() {
      var // The current element
      $this = $(this), // We store lots of great stuff using jQuery data
      data = $this.data(store) || {}, // This gets applied to the 'ps_container' element
      id = $this.attr('id') || $this.attr('name'), // This gets updated to be equal to the longest <option> element
      width = settings.width || $this.outerWidth(), // The completed ps_container element
      $ps = false;

      // Dont do anything if we've already setup processPopover on this element
      if (data.id) {
        return $this;
      } else {
        data.id = id;
        data.$this = $this;
        data.name = store;
        data.templates = templates;
        data.title = settings.title;
        data.message = settings.message;
        data.settings = settings;
      }

      // Hide the <select> list and place our new one in front of it
      $this.before($ps);

      // Save the updated $ps reference into our data object
      data.$ps = $ps;

      // Save the processPopover data onto the <this> element
      $this.data(store, data);

      $(this).click(_toggle);

      $(window).bind('resize.yellow_popover', function() {
        _refresh($this, data.name, data.id);
      });

      $(window).bind('_close.' + data.name + '.' + data.id, function() {
        var $ps = $("#" + data.name + "_" + data.id);
        _close($this, $ps);
      });

    });
  };

  // Build popover
  function _build(data) {
    var $ps = $(_.template(data.templates.main, {name:data.name, id:data.id, title: data.title, message:data.message}));

    $ps.bind('click', function(e) {
      e.stopPropagation();
    });

    return $ps;
  }

  // Close popover
  function _close($this, $ps) {
    var data = $this.data(store);
    GOD.unsubscribe("_close." + data.name + "." + data.id);

    if (is_ie) {
      $ps.hide();
      $ps.remove();
      $this.removeClass("open");
    } else {
      $ps.animate({top:$ps.position().top - 10, opacity:0}, 150, function() {
        $ps.remove();
        $this.removeClass("open");
      });
    }
  }

  // Refresh popover
  function _refresh($this, name, id) {
    var $ps = $("#" + name + "_" + id);
    if ($this.hasClass("open")) {

      var x = $this.offset().left;
      var y = $this.offset().top;
      var w = $ps.width();
      var h = $ps.height();

      if (oldIE) {
        $ps.css("top", y - h);
      } else {
        $ps.css("top", y - h);
      }

      $ps.css("left", x - w / 2 + 7);
    }
  }

  // Open a popover
  function _toggle(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var data = $this.data(store);

    if ($("#" + data.name + "_" + data.id).length != 0) {
      var $ps = $("#" + data.name + "_" + data.id);
      _close($this, $ps);
    } else {
      data.$ps = _build(data);
      var $ps = data.$ps;

      // setup the close event & signal the other subscribers
      var event = "_close." + data.name + "." + data.id;
      GOD.subscribe(event);
      GOD.broadcast(event);

      $("#content").prepend($ps);
      _center($this, $ps);

      if (oldIE) {
        $ps.show();
        $this.addClass("open");
      } else {
        $ps.animate({top:$ps.position().top + 10, opacity:1}, 150, function() {
          $this.addClass("open");
        });
      }
    }
  }

  function _center($this, $ps) {
    // link coordinates
    var x = $this.offset().left;
    var y = $this.offset().top;

    // link dimensions
    var lw = $this.attr("width");
    var lh = $this.attr("height");

    // popover dimensions
    var w = $ps.width();
    var h = $ps.height();

    $ps.css("left", x - w / 2 + lw / 2);

    if (oldIE) {
      $ps.css("top", y - h - 5);
    } else {
      $ps.css("top", y - h - 10);
    }
  }

  // Expose the plugin
  $.fn.processPopover = function(method) {
    if (!ie6) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      }
    }
  };

})(jQuery, window, document);

/*
* ============
* DATE POPOVER
* ============
*/

(function($, window, document) {

  var ie6 = false;

  // Help prevent flashes of unstyled content
  if ($.browser.msie && $.browser.version.substr(0, 1) < 7) {
    ie6 = true;
  } else {
    document.documentElement.className = document.documentElement.className + ' ps_fouc';
  }

  var // Public methods exposed to $.fn.datePopover()
  methods = {}, store = "datepopover", months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG", "SEP","OCT","NOV",
    "DEC"], templates = {
      main: ['<div id="<%=name %>_<%= id %>" class="date-selector">',
        '<div class="month"><span></span></div>',
        '<div class="day"><span></span></div>',
        '<div class="year"><span></span></div>',
        '</div>'].join(' '),
        input: '<input type="hidden" value="" id="datefield_<%= name %>_<%= id %>" name="<%= name %>" />'
    };

    // Some nice default values
    defaults = {
      transitionSpeed:150
    };

    // Called by using $('foo').datePopover();
    methods.init = function(settings) {
      settings = $.extend({}, defaults, settings);

      return this.each(function() {
        var // The current <select> element
        $this = $(this), // We store lots of great stuff using jQuery data
        data = $this.data(store) || {}, // This gets applied to the 'ps_container' element
        id = $this.attr('id') || $this.attr('name'), // This gets updated to be equal to the longest <option> element
        width = settings.width || $this.outerWidth(), // The completed ps_container element
        $ps = false;

        // Dont do anything if we've already setup datePopover on this element
        if (data.id) {
          return $this;
        } else {
          data.id = id;
          data.$this = $this;
          data.name = store;
          data.templates = templates;
          data.settings = settings;
        }

        // Update the reference to $ps
        $ps = $("#" + data.name + "_" + data.id);

        // Save the updated $ps reference into our data object
        data.$ps = $ps;

        // Save the datePopover data onto the <select> element
        $this.data(store, data);

        // Do the same for the dropdown, but add a few helpers
        $ps.data(store, data);

        // Add input field so we can submit the date in the form
        var $input = _buildInput(data);

        $this.before($input); // add the input to the DOM
        data.$input = $('#datefield_' + data.name + '_' + data.id);

        // Add the initial date to the hidden input field
        _captureDate($this);
        _updateDate($this);

        $this.click(_toggle);

        $(window).bind('_close.' + data.name + '.' + data.id, function() {
          var $ps = $("#" + data.name + "_" + data.id);
          _close($this, $ps);
        });
      });
    };

    // Build popover
    function _build(data) {
      var $ps = $(_.template(data.templates.main, {name:data.name, id:data.id}));

      $day = $ps.find(".day");
      $month = $ps.find(".month");
      $year = $ps.find(".year");

      $ps.bind('click', function(e) {
        e.stopPropagation();
      });

      return $ps;
    }

    // Build hidden input field that stores the date
    function _buildInput(data) {
      return $(_.template(data.templates.input, {name:data.name, id:data.id}));
    }

    // Open a popover
    function _toggle(e) {
      e.preventDefault();
      e.stopPropagation();

      var $this = $(this);
      var $day, $month, $year;
      var day, month, year;
      var data = $this.data(store);

      if ($(this).hasClass("open")) {
        var $ps = $("#" + data.name + "_" + data.id);
        _close($this, $ps);
      } else {

        data.$ps = _build(data);
        var $ps = data.$ps;

        // setup the close event & signal the other subscribers
        var event = "_close." + data.name + "." + data.id;
        GOD.subscribe(event);
        GOD.broadcast(event);

        $("#content").prepend($ps);
        _center($this, $ps);
        _setup($this, $ps);
        _captureDate($this);
        _setupLists($this, $ps);
        _bindLists($this, $ps);

        if (oldIE) {
          $ps.show();
          $this.addClass("open");
        } else {
          $ps.animate({top:$ps.position().top - 15, opacity:1}, data.settings.transitionSpeed, function() {
            $this.addClass("open");
          });
        }
      }
    }

    // Close popover
    function _close($this, $ps) {
      var data = $this.data(store);
      GOD.unsubscribe("_close." + data.name + "." + data.id);

      if (is_ie) {
        $ps.hide();
        $ps.remove();
        $this.removeClass("open");
      } else {
        $ps.animate({top:$ps.position().top - 10, opacity:0}, data.settings.transitionSpeed, function() {
          $ps.remove();
          $this.removeClass("open");
        });
      }
    }

    function _center($this, $ps) {
      var data = $this.data(store);

      var x = $this.offset().left;
      var y = $this.offset().top;
      var w = $ps.width();
      var el_w = $this.width();

      $ps.css("left", x - Math.floor(w / 2) + Math.floor(el_w / 2) - 4); // 4px == shadow

      if (oldIE) {
        $ps.css("top", y + 9);
      } else {
        $ps.css("top", y + 9 + 20);
      }
    }

    // Get the date from the <time> tag
    function _captureDate($this) {
      var date = new Date($this.attr("datetime"));

      day = date.getDate();
      month = date.getMonth();
      year = date.getFullYear();
    }

    // Setup the click events on each selector (year, month, day)
    function _setup($this, $ps) {
      $year.click(function(event) {
        event.stopPropagation();
        $(this).toggleClass("selected");
        $(".day, .month").removeClass("selected");
        var pane = $(this).find('.inner').jScrollPane({ verticalDragMinHeight: 20});
        pane.data('jsp').scrollToY(15 * (year - 1950));
      });

      $month.click(function(event) {
        event.stopPropagation();
        $(this).toggleClass("selected");
        $(".year, .day").removeClass("selected");
        var pane = $(this).find('.inner').jScrollPane({ verticalDragMinHeight: 20});
        pane.data('jsp').scrollToY(month);
      });

      $day.click(function(event) {
        event.stopPropagation();
        $(this).toggleClass("selected");
        $(".year, .month").removeClass("selected");
        var pane = $(this).find('.inner').jScrollPane({ verticalDragMinHeight: 20});
        pane.data('jsp').scrollToY(15 * (day - 1));
      });
    }


    // Bind click events on each of the items (1, 2, 3, january, february, 2011, 2012…)
    function _bindLists($this, $ps) {
      var data = $this.data(store);

      $year.find("li").click(function(event) {
        event.stopPropagation();
        year = $(this).html();

        _adjustCalendar();

        $year.find("li").removeClass("selected");
        $(this).addClass("selected");

        $year.find("span").animate({opacity:0}, data.settings.transitionSpeed, function() {
          $(this).html(year);
          $(this).animate({opacity:1}, data.settings.transitionSpeed);
        });
        $year.removeClass("selected");
        _updateDate($this);
      });

      $month.find("li").click(function(event) {
        event.stopPropagation();
        month = _.indexOf(months, $(this).html());

        _adjustCalendar();

        $month.find("li").removeClass("selected");
        $(this).addClass("selected");

        $month.find("span").animate({opacity:0}, data.settings.transitionSpeed, function() {
          $(this).html(months[month]);
          $(this).animate({opacity:1}, data.settings.transitionSpeed);
        });
        $month.removeClass("selected");
        _updateDate($this);
      });

      $day.find("li").click(function(event) {
        event.stopPropagation();
        day = $(this).html();

        $day.find("li").removeClass("selected");
        $(this).addClass("selected");

        $day.find("span").animate({opacity:0}, data.settings.transitionSpeed, function() {
          $(this).html(day);
          $(this).animate({opacity:1}, data.settings.transitionSpeed);
        });

        $day.removeClass("selected");
        _updateDate($this);
      });

    }

    function _setupLists($this, $ps) {
      $month.find("span").html(months[month]);
      $day.find("span").html(day);
      $year.find("span").html(year);

      $month.append('<div class="listing"><div class="inner"><ul></ul></div></div>');
      $day.append('<div class="listing"><div class="inner"><ul></ul></div></div>');
      $year.append('<div class="listing"><div class="inner"><ul></ul></div></div>');

      $ps.find('.listing, .jspVerticalBar').click(function(event) {
        event.stopPropagation();
      });

      _.each(months, function(m, index) {
        if (index == month) {
          $month.find(".listing ul").append('<li class="selected">' + m + '</li>');
        } else {
          $month.find(".listing ul").append("<li>" + m + "</li>");
        }
      });

      for (var i = 1; i <= 31; i++) {
        if (i == day) {
          $day.find(".listing ul").append("<li class='selected'>" + i + "</li>");
        } else {
          $day.find(".listing ul").append("<li>" + i + "</li>");
        }
      }

      for (var i = 1950; i <= 2020; i++) {
        if (i == year) {
          $year.find(".listing ul").append("<li class='selected'>" + i + "</li>");
        } else {
          $year.find(".listing ul").append("<li>" + i + "</li>");
        }
      }
    }

    function _zeroPad(num, count) {
      var numZeropad = num + '';
      while (numZeropad.length < count) {
        numZeropad = "0" + numZeropad;
      }
      return numZeropad;
    }

    // Update the original date contained in the <time> tag
    function _updateDate($this) {

      function _suffix(n) { // returns the appropriate suffix
        return [null, 'st', 'nd', 'rd', 'th'][n] || "th";
      }

      var data = $this.data(store);

      $this.html(months[month].toProperCase() + " " + day + _suffix(day) + ", " + year); // Visible date

      var datetime = year + "/" + _zeroPad(month + 1, 2) + "/" + day;
      $this.attr("datetime", datetime); // Tag's date
      data.$input.val(datetime.replace(/\//g, "-")); // Hidden input's date
    }

  // Adjust the selectors
  function _adjustCalendar() {
    var month_index = month + 1;

    if (month_index == 2) { // February has only 28 days
      var isLeap = new Date(year, 1, 29).getDate() == 29;

      if (isLeap) {
        $day.find("li").eq(28).show(); // leap year -> show 29th
      } else {
        $day.find("li").eq(28).hide(); // regular year -> hide 29th

        if (day > 28) {
          $day.find("li.selected").removeClass("selected");
          $day.find("li").eq(27).addClass("selected"); // select the 28th
          day = 28;
          $day.find("span").html(day)
        }
      }

      $day.find("li").eq(29).hide(); // 30
      $day.find("li").eq(30).hide(); // 31

    } else if (_.include([4, 6, 9, 11], month_index)) {
      $day.find("li").eq(30).hide(); // 31
    } else {
      $day.find("li").eq(28).show(); // 29
      $day.find("li").eq(29).show(); // 30
      $day.find("li").eq(30).show(); // 31
    }
  }

  // Expose the plugin
  $.fn.datePopover = function(method) {
    if (!ie6) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      }
    }
  };

})(jQuery, window, document);


/*
* =============
*  LINK POPOVER
* =============
*/

var linkPopover = (function() {
  var el;
  var displayed = false;
  var $popover;
  var transitionSpeed = 200;
  var links = {};

  var templates = {
    main:'<div class="white_narrow_popover"><div class="arrow"></div><ul></ul></div>',
    li:'<li><a href="<%=value%>"><span><%=label%></span></a></li>'
  }

  $(function() {
    $(window).bind('_close.linkpopover', hide);
  });

  function toggle(e, event, opt) {
    event.stopPropagation();
    event.preventDefault();
    el = e;

    if (opt) {
      links = opt.links
    }

    displayed ? hide() : show();
  }

  function setupInterface() {
    _.each(links, addLink);
    $popover.find("ul li:first-child").addClass("first");
    $popover.find("ul li:last-child").addClass("last");
  }

  function addLink(value, label) {
    $popover.find("ul").append(_.template(templates.li, {value:value, label:label}));
  }

  function hide() {
    GOD.unsubscribe("_close.linkpopover");

    if (is_ie) {
      $popover.hide();
      $popover.remove();
      displayed = false;
    } else {
      $popover.animate({top:$popover.position().top - 20, opacity:0}, transitionSpeed, function() {
        $popover.remove();
        displayed = false;
      });
    }
  }

  function showPopover() {
    // get the coordinates and width of the popover
    var x = el.find("span").offset().left;
    var y = el.find("span").offset().top;
    var w = $(".white_narrow_popover").width();

    // center the popover
    $popover.css("left", x - w / 2 + 4);

    // setup the close event & signal the other subscribers
    var event = "_close.linkpopover";
    GOD.subscribe(event);
    GOD.broadcast(event);

    if (is_ie) {
      $popover.css("top", y - 5);
      $popover.show(transitionSpeed, function() {
        displayed = true;
      });
    } else {
      $popover.css("top", y + 15);
      $popover.animate({top:$popover.position().top - 20, opacity:1}, transitionSpeed, function() {
        displayed = true;
      });
    }
  }

  function show() {
    $("#content").prepend(templates.main);
    $popover = $(".white_narrow_popover");
    setupInterface();

    showPopover();
  }

  return {
    toggle: toggle
  };
})();


/*
* ========
* DROPDOWN
* ========
*/

(function($, window, document) {

  var ie6 = false;

  // Help prevent flashes of unstyled content
  if ($.browser.msie && $.browser.version.substr(0, 1) < 7) {
    ie6 = true;
  } else {
    document.documentElement.className = document.documentElement.className + ' ps_fouc';
  }

  var // Public methods exposed to $.fn.dropdownPopover()
  methods = {}, store = "sortpopover", // HTML templates for the popover
  templates = {
    main: [
      '<div id="<%= name %>_<%= id %>" class="white_popover">',
      '<div class="arrow"></div>',
      '<ul></ul>',
      '</div>'].join(''),
      item: '<li data-select="<%= select %>"><a href="#"><span><%= name %></span></a></li>'
  }, // Some nice default values
  defaults = {
  };

  // Called by using $('foo').dropdownPopover();
  methods.init = function(settings) {
    settings = $.extend({}, defaults, settings);

    return this.each(function() {
      var // The current <select> element
      $this = $(this), // We store lots of great stuff using jQuery data
      data = $this.data(store) || {}, // This gets applied to the 'ps_container' element
      id = $this.attr('id') || $this.attr('name'), // This gets updated to be equal to the longest <option> element
      width = settings.width || $this.outerWidth(), // The completed ps_container element
      $ps = false;

      // Dont do anything if we've already setup dropdownPopover on this element
      if (data.id) {
        return $this;
      } else {
        data.id = id;
        data.$this = $this;
        data.name = store;
        data.settings = settings;
        data.templates = templates;
      }

      // Update the reference to $ps
      $ps = $("#" + data.name + "_" + data.id);

      // Save the updated $ps reference into our data object
      data.$ps = $ps;

      // Save the dropdownPopover data onto the <select> element
      $this.data(store, data);

      // Do the same for the dropdown, but add a few helpers
      $ps.data(store, data);
      $this.click(_toggle);

      $(window).bind('resize.' + data.name + "_" + data.id, function() {
        _refresh($this, data.name, data.id);
      });

      $(window).bind('_close.' + data.name + '.' + data.id, function() {
        _hide($this, data.name, data.id);
      });

    });
  };

  function _buildItems($ps, data) {

    if (data.settings.options && data.settings.options.links) {

      _.each(data.settings.options.links, function(option, i) {
        var select = ("select" in option) ? option.select : option.name;

        var $item = _.template(data.templates.item, {name:option.name, select:select});

        $ps.find("ul").append($item);

        $ps.find("ul li:last a").click(function(e) {

          option.callback(e); // execute the callback function

          _close(data.$this, data.name, data.id); // and close the popover

          // Replace the original link with…
          var replacementText;

          if ("replaceWith" in option) { // … a text provided by the user
            replacementText = option.replaceWith;
          } else { // the name of the selected option
            replacementText = $(this).html();
          }
          data.$this.html(replacementText);
        });
      });

      // we need to add these classes for iE
      $ps.find("ul li:first").addClass("first");
      $ps.find("ul li:last").addClass("last");
    }
  }

  // Build popover
  function _build(data, selectedOption) {

    var $ps = $(_.template(data.templates.main, {id:data.id, name:data.name}));

    $ps.bind('click', function(e) {
      e.stopPropagation();
    });

    return $ps;
  }

  // Highlights the selected option
  function _selectOption($ps, optionText) {
    $ps.find("li.selected").removeClass("selected");
    $ps.find('li[data-select="' + optionText + '"]').addClass("selected");
  }

  // Refresh popover
  function _refresh($this, name, id) {
    var $ps = $("#" + name + "_" + id);

    if ($this.hasClass("open")) {

      var x = $this.find("span").offset().left;
      var y = $this.find("span").offset().top;
      var tw = $this.find("span").width();
      var w = $ps.width();

      if (oldIE) {
        $ps.css("top", y);
      } else {
        $ps.css("top", y);
      }

      $ps.css("left", x - w / 2 + tw / 2);
    }
  }

  // Center popover
  function _center($this, $ps) {
    var x = $this.find("span").offset().left;
    var y = $this.find("span").offset().top;
    var tw = $this.find("span").width();

    var w = $ps.width();

    $ps.css("left", x - w / 2 + tw / 2);

    if (oldIE) {
      $ps.css("top", y - 5);
    } else {
      $ps.css("top", y - 15);
    }
  }

  function _hide($this, name, id) {
    _close($this, name, id);
  }

  // Close popover
  function _close($this, name, id) {
    var $ps = $("#" + name + "_" + id);
    GOD.unsubscribe("_close." + name + "." + id);

    if (oldIE) {
      $ps.hide();
      $ps.remove();
      $this.removeClass("open");
    } else {
      $ps.animate({top:$ps.position().top - 20, opacity:0}, 150, function() {
        $ps.remove();
        $this.removeClass("open");
      });
    }
  }

  // Open a popover
  function _toggle(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var data = $this.data(store);

    if ($(this).hasClass("open")) {
      _close($this, data.name, data.id);
    } else {

      data.$ps = _build(data);
      var $ps = data.$ps;

      // setup the close event & signal the other subscribers
      var event = "_close." + data.name + "." + data.id;
      GOD.subscribe(event);
      GOD.broadcast(event);

      $("#content").prepend($ps);
      _buildItems($ps, data);
      _center($this, $ps);
      _selectOption($ps, $(this).text());

      if (oldIE) {
        $ps.show();
        $this.addClass("open");
      } else {
        $ps.animate({top:$ps.position().top + 15, opacity:1}, 150, function() {
          $this.addClass("open");
        });
      }
    }
  }

  // Expose the plugin
  $.fn.dropdownPopover = function(method) {
    if (!ie6) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      }
    }
  };
})(jQuery, window, document);


var dialogPopover = (function() {

  var
  el              = null,
  displayed       = false,
  transitionSpeed = 50;

  function toggle(e, event, div) {
    event.stopPropagation();
    event.preventDefault();
    el = e;
    $popover = $(div);

    displayed ? hide() : show();

    $popover.find(".scrollpane").jScrollPane({
      showArrows: true
    });
  }

  function getTopPosition() {

    return $(el).position().top;
    //return (( $(window).height() - $popover.height()) / 2) + $(window).scrollTop() - 50;
  }

  function setupBindings() {
    $popover.find(".about").click(function(event) {
      event.preventDefault();
      displayed && hide(function() {
        window.location.href = $(this).attr("href");
      });
    });

    $popover.find(".close").click(function(event) {
      event.preventDefault();
      displayed && hide();
    });

    $popover.click(function(event) {
      event.stopPropagation();
    });
  }

  function show() {
    setupBindings();
    $popover.css("top", getTopPosition() + "px");
    $popover.fadeIn("slow", function() {
      hidden = false;
    });

    displayed = true;
  }

  function hide(callback) {
    $popover.find('a.close').unbind("click");

    $popover.fadeOut(transitionSpeed, function() {
      $popover.hide();
      displayed = false;
    });
  }

  return {
    toggle: toggle,
    hide: hide
  };
})();

/*
* ================
* DOWNLOAD POPOVER
* ================
*/
var download = (function() {
  var
  el,
  callback,
  displayed       = false,
  transitionSpeed = 200;
  // reusing the ID based disclaimer CSS rules - they can't both exist at the same time
  var template = ['<div id="download_popover" class="infowindow">',
        '<div class="lheader"></div>',
        '<div class="content">',
          '<h2>Confirmation</h2>',
          '<p>You are about to run a very large download (more than a million records).</p>',
          '<p>While this system is still in testing phase, please be considerate and don\'t run very large downloads unless you really need them.</p>',
          '<p>Running a large download involves significant processing, which might reduce service levels for others.</p>',
          '<p>Also, please be aware that downloads on this scale may return data running to hundreds of gigabytes.</p>',
          '<a id="run-download" class="candy_blue_button close"><span>OK, run the download</span></a>',
          '<a class="candy_blue_button close" style="margin-right:20px"><span>Cancel</span></a>',
        '</div>',
        '<div class="lfooter white">',
        '</div>',
      '</div>'].join(' ');

  function toggle(e, event, cb) {
    event.stopPropagation();
    event.preventDefault();
    el = e;
    callback = cb;
    displayed ? hide() : show();
  }

  function getTopPosition() {
    return (( $(window).height() - $popover.height()) / 2) + $(window).scrollTop() - 50;
  }

  function setupBindings() {
    $popover.find(".close").click(function(event) {
      event.preventDefault();
      displayed && hide();
    });

    $popover.find("#run-download").click(function (event) {
      callback(); // run it
    });

    $popover.click(function(event) {
      event.stopPropagation();
    });
  }

  function show() {
    $("#content").prepend(template);
    $popover = $("#download_popover");

    setupBindings();
    $popover.css("top", getTopPosition() + "px");
    $popover.fadeIn("slow", function() {
      hidden = false;
    });

    $("body").append("<div id='lock_screen'></div>");
    $("#lock_screen").height($(document).height());
    $("#lock_screen").fadeIn("slow");
    $("#lock_screen").on("click", hide);

    displayed = true;
  }

  function hide(callback) {
    $popover.find('a.close').unbind("click");

    $popover.fadeOut(transitionSpeed, function() {
      $popover.remove();
      displayed = false;
    });

    $("#lock_screen").fadeOut(transitionSpeed, function() {
      $("#lock_screen").remove();
      callback && callback();
    });
  }

  return {
    toggle: toggle,
    show: show,
    hide: hide
  };
})();

/*
* ================
* POPOVER BINDINGS
* ================
*/

$.fn.bindSlider = function(min, max, values) {
  var $slider = $(this).find(".slider");
  var $legend = $(this).find(".legend");

  $slider.slider({
    range: true,
    min: min,
    max: max,
    values: values,
    slide: function(event, ui) {
      $legend.val("BETWEEN " + ui.values[ 0 ] + " AND " + ui.values[ 1 ]);
    }
  });

  $legend.val("BETWEEN " + $slider.slider("values", 0) + " AND " + $slider.slider("values", 1));
};

$.fn.bindLinkPopover = function(opt) {
  $(this).click(function(event) {
    linkPopover.toggle($(this), event, opt);
  });
};

$.fn.bindDatePopover = function() {
  $(this).click(function(event) {
    datePopover.toggle($(this), event);
  });
};

$.fn.bindDialogPopover = function(opt) {
  $(this).click(function(event) {
    dialogPopover.toggle($(this), event, opt);
  });
};




/*
* ==============
* SPECIES IMAGES
* ==============
*/

$.fn.speciesSlideshow = function(usageID) {
  var $this = $(this);

  var
  slideData        = [],
  photoWidth       = 627,
  photoHeight      = 442,
  currentPhoto     = 0,
  transitionSpeed  = 500,
  easingMethod     = "easeOutQuart",

  $previousCtr     = $this.find(".previous"),
  $nextCtr         = $this.find(".next"),
  $scroller        = $this.find(".scroller"),
  $metadata        = $this.find(".scrollable");
  $imgCounter      = $this.find(".counter");

  $(this).hide();

  var url = cfg.wsClb + "species/" + usageID + "/images?callback=?";

  $.getJSON(url, initImageData);

function updateMetadata(currentPhoto, data) {
  $imgCounter.text(1+currentPhoto + " / " + slideData.length);

  // remove all other metadata
  $metadata.empty();

  // title is special
  $metaTitle = $this.find(".title");
  $metaTitle.fadeOut(150, function() {
    if (data.title) {
      $metaTitle.html(limitText(data.title, 60));
      $metaTitle.attr("title", data.title);
    } else {
      $metaTitle.html("No title");
    }
    $metaTitle.fadeIn(150);
  });

  // add source
  $srcLink = data.link;
  if (!data.link && data.usageKey != usageID) {
    $srcLink = cfg.baseUrl + '/species/' + data.usageKey;
  }
  if ($srcLink) {
    // load dataset title and keep it with image
    getDatasetDetail(data.datasetKey, function(dataset) {
      $metadata.prepend("<h3>Source</h3><p><a title='" + dataset.title + "' href='" + $srcLink + "'>" + limitText(dataset.title, 28) +"</a></p>");
    });
  }

  updateMetaProp("Image publisher", data.publisher, null);
  if (data.creator || data.created) {
    if (data.creator && data.created) {
      $val = data.creator + ", " + data.created;
    } else if (data.creator) {
      $val = data.creator;
    } else {
      $val = data.created;
    }
    updateMetaProp("Photographer", $val, null);
  }
  updateMetaProp("Copyright", data.license, "No license provided");
  updateMetaProp("Description", data.description, null);

}

function updateMetaProp(prop, value, defaultValue) {
  if (!value) {
    value = defaultValue;
  }
  if (value) {
    $metadata.append("<h3>"+prop+"</h3><p>" + value +"</p>");
  }
}

function activateNextController() {
  $nextCtr.show();
  $nextCtr.click(function(event) {
    event.preventDefault();

    if (currentPhoto == 0) {
      activatePrevController();
    }

    $scroller.scrollTo('+=' + photoWidth + 'px', transitionSpeed, { easing:easingMethod, axis:'x' });
    currentPhoto++;
    updateMetadata(currentPhoto, slideData[currentPhoto]);

    if (currentPhoto == slideData.length - 1) {
      deactivateController($nextCtr);
    }
  });
}
function activatePrevController() {
  $previousCtr.show();
  $previousCtr.click(function(event) {
    event.preventDefault();

    if (currentPhoto == slideData.length - 1) {
      activateNextController();
    }
    $scroller.scrollTo('-=' + photoWidth + 'px', transitionSpeed, { easing:easingMethod, axis:'x'} );
    currentPhoto--;
    updateMetadata(currentPhoto, slideData[currentPhoto]);

    if (currentPhoto == 0) {
      deactivateController($previousCtr);
    }
  });
}
function deactivateController(controller) {
  controller.hide();
  controller.off('click');
}

function initImageData(data) {

  $this.show();

  var images = data.results;
  var $photos = $scroller.find(".photos");
  var n = 0;

  _.each(images, function(imgJson) {
    n++;
    slideData.push(imgJson);

    $photos.append("<li><div class='spinner'></div><a href='"+imgJson.image+"' class='fancybox' title='"+imgJson.title+"'><img id='photo_"+n+"'src='" + imgJson.image + "' /></a></li>");

    var $img = $photos.find("#photo_" + n);

    $img.on("load", function() {

      $(this).parent().parent().find(".spinner").fadeOut(100, function() { $(this).remove(); });

      var
      h   = parseInt($(this).css("height"), 10),
      w   = parseInt($(this).css("width"), 10);
      $img.css("top", photoHeight/2 - h/2 );
      $img.css("left", photoWidth/2 - w/2 );
      $img.fadeIn(100);
    });

  });

  updateMetadata(0, slideData[0]);

  $photos.css("width", slideData.length * photoWidth);

  // attach fancybox links
  $photos.find("a").fancybox({
 		'transitionIn'	:	'elastic',
 		'transitionOut'	:	'elastic',
 		'speedIn'		:	600,
 		'speedOut'		:	200,
 		'overlayShow'	:	false
 	});
  //console.log(slideData.length + " photos loaded");

  if (slideData.length == 1) {
    $this.find("div.controller").remove();
  } else {
    activateNextController();
    deactivateController($previousCtr);
  }
}

};




/*
* ==========
* SELECT BOX
* ==========
*/

(function($, window, document) {

  var ie6 = false;

  // Help prevent flashes of unstyled content
  if ($.browser.msie && $.browser.version.substr(0, 1) < 7) {
    ie6 = true;
  } else {
    document.documentElement.className = document.documentElement.className + ' ps_fouc';
  }

  var // Public methods exposed to $.fn.selectBox()
  methods = {}, store = "selectbox", // HTML template for the dropdowns
  templates = {
    main: ['<div id="<%= name %>_<%= id %>" class="select_box">',
      '<div class="selected_option"><span><%= label %></span></div>',
      '</div>'].join(''),
      list:['<div id="list_<%= name %>_<%= id %>" class="select_listing">',
        '<div class="select_inner">',
        '<ul><%= options %></ul>',
        '</div>',
        '</div>'].join(' ')
  }, // Some nice default values
  defaults = {
    transitionSpeed: 150
  };
  // Called by using $('foo').selectBox();
  methods.init = function(settings) {
    settings = $.extend({}, defaults, settings);

    return this.each(function() {
      var // The current <select> element
      $this = $(this), // We store lots of great stuff using jQuery data
      data = $this.data(store) || {}, // This gets applied to the 'ps_container' element
      id = $this.attr('id') || $this.attr('name'), // This gets updated to be equal to the longest <option> element
      width = settings.width || $this.outerWidth(), // Save all of the <option> elements
      $options = $this.find('option'), $original = $this.find(':selected').first();

      // The completed ps_container element
      $ps = false;

      // Dont do anything if we've already setup selectBox on this element
      if (data.id) {
        return $this;
      } else {
        data.id = id;
        data.$this = $this;
        data.settings = settings;
        data.templates = templates;
        data.$original = $original;
        data.name = store;
        data.options = $options;
        data.label = $original.html();
        data.value = _notBlank($this.val()) || _notBlank($original.attr('value'));
      }

      // Build the dropdown HTML
      $ps = _build(templates.main, data);
      $l = _buildItems(templates.list, data);

      $this.hide();

      data.$l = $l;

      // Hide the <select> list and place our new one in front of it
      $this.before($ps);

      // Update the reference to $ps
      $ps = $('#' + data.name + "_" + data.id);

      $ps.css("width", width + 35);
      $l.css("width", width + 23);

      // Save the updated $ps reference into our data object
      data.$ps = $ps;

      // Save the selectBox data onto the <select> element
      $this.data(store, data);

      // Do the same for the dropdown, but add a few helpers
      $ps.data(store, data);

      $("#content").append($l);

      $ps.click(_toggle);

      $(window).bind("_close." + data.name + "." + data.id, function(e) {
        _close($this);
      });
    });
  };

  // Build popover
  function _build(template, data) {
    var $ps = _.template(template, {label:data.label, name:data.name, id:data.id});

    return $ps;
  }

  function _buildItems(template, data) {
    var options = "";
    var c = "";

    for (var i = 0; i < data.options.length; i++) {

      var value = $(data.options[i]).val();
      var name = $(data.options[i]).html();
      if (value) {
        c = (value == data.value) ? ' class="selected"' : '';
        options += '<li' + c + ' data-dropdown-value="' + value + '">' + name + '</li>';
      }
    }
    ;

    return $(_.template(template, {name:data.name, id:data.id, options:options}));
  }

  // Close popover
  function _close($this) {
    var data = $this.data(store);
    GOD.unsubscribe("_close." + data.name + "." + data.id);
    data.$ps.removeClass("open");
    data.$l.removeClass("open");
  }

  function _notBlank(text) {
    return ($.trim(text).length > 0) ? text : false;
  }

  // Open a popover
  function _toggle(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var data = $this.data(store);
    var $ps = $('#' + data.name + "_" + data.id);
    var $l = $('#list_' + data.name + "_" + data.id);

    if ($ps.hasClass("open")) {
      _close($this);
    } else {

      $l.addClass("open");
      $ps.addClass("open");

      // don't do anything if we click inside of the select…
      $l.find('.listing, .jspVerticalBar').click(function(e) {
        e.stopPropagation();
      });

      $l.find('ul').jScrollPane({ verticalDragMinHeight: 20});

      $l.css("top", $ps.offset().top + 34);
      $l.css("left", $ps.offset().left);

      $l.find("li").unbind("click");
      $l.find("li").click(function(event) {
        var text = $(this).text();

        $l.find("li").removeClass("selected");
        $(this).addClass("selected");

        // select the option in the original select
        var value = $(this).attr('data-dropdown-value');
        data.$this.val(value);

        $ps.find("div.selected_option span").animate({ color: "#FFFFFF" }, data.settings.transitionSpeed, function() {
          $ps.find("div.selected_option span").text(text);
          $ps.find("div.selected_option span").animate({ color: "#333" }, data.settings.transitionSpeed);
        });

        _close($ps);
      });

      // setup the close event & signal the other subscribers
      var event = "_close." + data.name + "." + data.id;
      GOD.subscribe(event);
      GOD.broadcast(event);
    }
  }

  // Expose the plugin
  $.fn.selectBox = function(method) {
    if (!ie6) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      }
    }
  };


})(jQuery, window, document);


/*
* ================
* CRITERIA POPOVER
* ================
*/

(function($, window, document) {

  var ie6 = false;

  // Help prevent flashes of unstyled content
  if ($.browser.msie && $.browser.version.substr(0, 1) < 7) {
    ie6 = true;
  } else {
    document.documentElement.className = document.documentElement.className + ' ps_fouc';
  }

  var // Public methods exposed to $.fn.criteriaPopover()
  methods = {}, store = "criteria_popover", // HTML template for the dropdowns
  templates = {
    main: [
      '<div class="criteria_popover" id="criteria_popover_<%= id %>">',
      '<a href="#" class="select"><%= title %></a>',
      '<div class="criterias">',
      '<div class="arrow"></div>',
      '<div class="background">',
      '<div class="l">',
      '<div class="scrollpane"><ul class="criterias_inner"></ul></div>',
      '</div>',
      '</div>',
      '</div>',
      '<div class="selected_criterias"></div>',
      '<a href="#" class="more">Add more</a>',
      '</div>'
      ].join(''),
      li: '<li><a data-criteria="<%= criteria %>"><span class="label"><%= text %><span></a></li>',

      // Templates for the criterias
      range: ['<div class="refine" data-criteria="<%= criteria %>">',
        '<div id="<%= criteria %>_<%= name %>_<%= id %>" class="range"><h4>RANGE</h4> <input type="text" value="" class="legend" /><div class="slider"><div class="ui-slider-handle"></div><div class="ui-slider-handle last"></div></div></div>',
        '</div>'].join(' '),

        date: ['<div class="refine" data-criteria="<%= criteria %>">',
          '<h4>Date</h4><time id="<%= criteria %>_<%= name %>_<%= id %>_start" class="selectable" datetime="2012/10/22">Oct 22th, 2012</time>  - <time class="selectable" datetime="1981/06/18" id="<%= criteria %>_<%= name %>_<%= id %>_end">Jun 18th, 1981</time>',
          '</div>'].join(' ')
  }, // Some nice default values
  defaults = { };
  // Called by using $('foo').criteriaPopover();
  methods.init = function(settings) {
    settings = $.extend({}, defaults, settings);

    return this.each(function() {
      var // The current <select> element
      $this = $(this), // Save all of the <option> elements
      $options = $this.find('option'), // We store lots of great stuff using jQuery data
      data = $this.data(store) || {}, // This gets applied to the 'criteria_popover' element
      id = $this.attr('id') || $this.attr('name'), // This gets updated to be equal to the longest <option> element
      width = settings.width || $this.outerWidth(), // The completed criteria_popover element
      $ps = false;

      // Dont do anything if we've already setup criteriaPopover on this element
      if (data.id) {
        return $this;
      } else {
        data.settings = settings;
        data.id = id;
        data.name = store;
        data.w = 0;
        data.$this = $this;
        data.options = $options;
        data.templates = templates;
      }

      // Build the dropdown HTML
      $ps = _build(templates.main, data);

      // Hide the <$this> list and place our new one in front of it
      $this.before($ps);

      // Update the reference to $ps
      $ps = $('#criteria_popover_' + id).fadeIn(settings.startSpeed);

      // "Add more" action
      $ps.find('.more').live("click", function(e) {
        e.preventDefault();
        e.stopPropagation();

        var $option = $(this), $ps = $option.parents('.criteria_popover').first(), data = $ps.data(store);

        _toggle(e, $ps);
      });

      // Save the updated $ps reference into our data object
      data.$ps = $ps;

      $ps.find('.criterias .scrollpane').jScrollPane({ verticalDragMinHeight: 20});

      // Save the $this data onto the <$this> element
      $this.data(store, data);

      // Do the same for the dropdown, but add a few helpers
      $ps.data(store, data);

      // hide the source of the data
      $this.hide();

      $ps.find(".select").click(function(e) {
        _toggle(e, $this)
      });

      $(window).bind('_close.' + data.name + '.' + data.id, function() {
        var $ps = $("#" + data.name + "_" + data.id);
        _close($this);
      });
    });
  };

  // private methods
  function _build(tpl, data) {

    var $ps = $(_.template(tpl, { id:data.id, title:data.$this.html()}));
    var elements = [];
    var max_width = 0;

    _buildItems($ps, data);

    return $ps;
  }

  // Add the items to the list of criterias
  function _buildItems($ps, data) {
    if (data.settings.options && data.settings.options.criterias) {

      _.each(data.settings.options.criterias, function(option, i) {
        var $item = _.template(data.templates.li, {criteria:option.criteria, text:option.label});

        $ps.find("ul.criterias_inner").append($item);
      });

      // we need to add these classes for iE
      $ps.find("ul li:first").addClass("first");
      $ps.find("ul li:last").addClass("last");
    }
  }

  // Close a dropdown
  function _close($this) {
    var data = $this.data(store);
    GOD.unsubscribe("_close." + data.name + "." + data.id);

    data.$ps.removeClass('ps_open');
  }

  // Open a dropdown

  function _toggle(e, $this) {
    e.preventDefault();
    e.stopPropagation();

    var data = $this.data(store);
    var $ps = data.$ps;

    // setup the close event & signal the other subscribers
    var event = "_close." + data.name + "." + data.id;
    GOD.subscribe(event);
    GOD.broadcast(event);

    if ($ps.hasClass("ps_open")) {
      $ps.removeClass('ps_open');
    } else {

      $ps.addClass('ps_open');

      var w = $ps.find("ul.criterias_inner").width();
      var h = $ps.find("ul.criterias_inner").height()

      var widerElement = _.max($ps.find(".criterias li"), function(f) {
        return $(f).width()
      });
      w = $(widerElement).width();

      if (w > data.w) {
        data.w = w;
      }

      $ps.find(".criterias .background").width(data.w + 15);
      var api = $ps.find(".criterias .scrollpane").data('jsp');
      api.reinitialise();

      // Uncomment the following line to reset the scroll
      // api.scrollTo(0, 0);

      $ps.find(".jspContainer").width(data.w + 15);
      $ps.find(".jspPane").width(data.w + 15);

      var $select = $ps.find(".select:visible");

      if ($select.length < 1) {
        $select = $ps.find(".more");
      }

      var x = $select.position().left;
      var y = $select.position().top;
      var w = $ps.find(".criterias").width();
      var h = $ps.find(".criterias").height();

      $ps.find(".criterias").css("left", x - w / 2 + 40);
      $ps.find(".criterias").css("top", y + 5);

      $ps.find('.jspVerticalBar').click(function(e) {
        e.stopPropagation();
      });
    }
  }

  $(function() {

    // Bind remove action over an element (for a future implementation)
    $('.selected_criterias .remove').live('click', function(e) {

      var $option = $(this);
      var $ps = $option.parents('.criteria_popover').first();
      var count = $ps.find(".selected_criterias > div").length;

      var countSelected = $ps.find(".selected_criterias > div").length;
      var countOptions = $ps.find(".criterias_inner li").length;

      if (count <= 1) {
        $ps.find(".select").show();
        $ps.find(".more").hide();
      } else if (count == countOptions) {
        $ps.find(".more").show();
      }

      var selected = $option.parent().attr('data-criteria');

      // Remove the element from the temporary list
      $option.parent().remove();

      // Remove the hide class
      var $selected_element = $ps.find("ul.criterias_inner li a[data-criteria=" + selected + "]").parent();

      $selected_element.removeClass("hidden");
      _close($ps);
    });

    // Bind click action over an original element
    $('.criterias a').live('click', function(e) {

      e.preventDefault();
      e.stopPropagation();

      var $option = $(this);
      var $ps = $option.parents('.criteria_popover').first();
      var data = $ps.data(store);

      var $selected_element = $ps.find(".selected_criterias > div a[data-criteria=" + $option.attr("data-criteria") +
        "]").parent();

      if ($selected_element.length < 1) {

        $ps.find("a.select").hide();

        var countSelected = $ps.find(".selected_criterias > div").length;
        var countOptions = $ps.find(".criterias_inner li").length;

        _close($ps);

        if (countSelected + 1 < countOptions) {
          $ps.find("a.more").show();
        } else {
          $ps.find("a.more").hide();
        }

        $selected = $option.parent();
        $selected.addClass('hidden');

        // Append the criteria selector to the DOM
        var criteria = $selected.find("a").attr("data-criteria");
        var $criteria = _.template(data.templates[criteria], {criteria: criteria, name:data.name, id:data.id});
        $ps.find(".selected_criterias").append($criteria);

        // Criteria activations/callbacks
        if (criteria == "range") {
          $criteria = $('.selected_criterias #' + criteria + '_' + data.name + '_' + data.id);

          $criteria.parent().show("fast");
          $criteria.bindSlider(0, 500, [0, 500]);

        } else if (criteria == "date") {

          var $criteria_start = $('.selected_criterias #' + criteria + '_' + data.name + '_' + data.id + '_start');
          var $criteria_end = $('.selected_criterias #' + criteria + '_' + data.name + '_' + data.id + '_end');

          $criteria = $criteria_start;
          $criteria.parent().show("fast");
          $criteria_start.datePopover();
          $criteria_end.datePopover();
        }
      }
    });
  });

  // Expose the plugin
  $.fn.criteriaPopover = function(method) {
    if (!ie6) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      }
    }
  };

})(jQuery, window, document);
