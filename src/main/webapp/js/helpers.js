var is_ie = $.browser.msie;
var broswer_version = parseInt($.browser.version, 10);
var oldIE = is_ie && $.browser.version.substr(0, 1) < 9;

String.prototype.toProperCase = function () {
  return this.replace(/\w\S*/g, function(txt) {
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
  });
};

// copied from http://stackoverflow.com/questions/10191941/jquery-unique-on-an-array-of-strings
Array.prototype.unique = function () {
  var arr = this;
  return $.grep(arr,function(el,index){
      return index == $.inArray(el,arr);
  });
}

function addCommas(str) {
    var amount = new String(str);
    amount = amount.split("").reverse();

    var output = "";
    for ( var i = 0; i <= amount.length-1; i++ ){
        output = amount[i] + output;
        if ((i+1) % 3 == 0 && (amount.length-1) !== i)output = ',' + output;
    }
    return output;
}

function generateRandomValues(limit) {
  var last = Math.floor(Math.random() * 500);
  var random = 0;
  var values = [];
  var s = 0;

  for (var i = 0; i <= limit; i++) {
    s = Math.floor(Math.random() * 100);

    if (s > 80 && s < 90) {
      random = last + Math.floor(Math.random() * last);
      values[i] = random;
    } else if (s > 95) {
      random = last - Math.floor(Math.random() * last);
      values[i] = random;
    } else {
      values[i] = last + Math.floor(Math.random() * 100);
    }
    last = values[i];
  }
  return values;
}


function sortByCount($ul) {
  $ul.find(" > li").sortList(function(a, b) {
    return parseInt($(a).attr("data")) > parseInt($(b).attr("data")) ? 1 : -1;
  });

  $ul.children().each(function() {
    sortByCount($(this))
  });
}

function sortAlphabetically($ul) {
  $ul.find(" > li").sortList(function(a, b) {
    return $(a).find("span").text() > $(b).find("span").text() ? 1 : -1;
  });

  $ul.children().each(function() {
    sortAlphabetically($(this));
  });
}

/**
 * jQuery.fn.sort
 * --------------
 * @author James Padolsey (http://james.padolsey.com)
 * @version 0.1
 * @updated 18-MAR-2010
 * --------------
 * @param Function comparator:
 *   Exactly the same behaviour as [1,2,3].sort(comparator)
 *
 * @param Function getSortable
 *   A function that should return the element that is
 *   to be sorted. The comparator will run on the
 *   current collection, but you may want the actual
 *   resulting sort to occur on a parent or another
 *   associated element.
 *
 *   E.g. $('td').sort(comparator, function(){
 *      return this.parentNode;
 *   })
 *
 *   The <td>'s parent (<tr>) will be sorted instead
 *   of the <td> itself.
 */
jQuery.fn.sortList = (function() {

  var sort = [].sort;

  return function(comparator, getSortable) {

    getSortable = getSortable || function() {
      return this;
    };

    var placements = this.map(function() {

      var sortElement = getSortable.call(this),
        parentNode = sortElement.parentNode,

        // Since the element itself will change position, we have
        // to have some way of storing it's original position in
        // the DOM. The easiest way is to have a 'flag' node:
        nextSibling = parentNode.insertBefore(document.createTextNode(''), sortElement.nextSibling);

      return function() {

        if (parentNode === this) {
          throw new Error("You can't sort elements if any one is a descendant of another.");
        }

        // Insert before flag:
        parentNode.insertBefore(this, nextSibling);
        // Remove flag:
        parentNode.removeChild(nextSibling);

      };

    });

    return sort.call(this, comparator).each(function(i) {
      placements[i].call(getSortable.call(this));
    });

  };

})();


function setupZoom(map) {
  // add custom controls
  var container = $(map.getContainer());
  container.before('<div class="zoom_in"></div> <div class="zoom_out"></div>  <div class="zoom_fs"></div>');

  var minZoom = 0;
  var fsControl = new ZoomFullscreen(map);

  $(".zoom_in", container.parent()).click(function() {
    map.setZoom(map.getZoom() + 1);
  });

  $(".zoom_out", container.parent()).click(function() {
    var zoom;
    if ( map.getZoom() > minZoom ) {
      map.setZoom(map.getZoom() - 1);
    }
  });

  $(".zoom_fs", container.parent()).click(function() {
    fsControl.fullscreen();
  });
}

var ZoomFullscreen = function(map) {
  this._map = map;
  this._isFullscreen = false;
}
ZoomFullscreen.prototype.fullscreen = function(){
    // call appropriate internal function
	  if (!this._isFullscreen) {
	    this._enterFullScreen();
	  }else{
	    this._exitFullScreen();
	  };

    // force internal resize
	  this._map.invalidateSize();
  };
 ZoomFullscreen.prototype._enterFullScreen = function(){
    var container = this._map._container;

    // apply our fullscreen settings
    container.style.position = 'fixed';
		container.style.left = 0;
		container.style.top = 0;
		container.style.width = '100%';
		container.style.height = '100%';

    // store state
    L.DomUtil.addClass(container, 'leaflet-fullscreen');
	  this._isFullscreen = true;

	  // add ESC listener
	  L.DomEvent.addListener(document, 'keyup', this._onKeyUp, this);

    // fire fullscreen event on map
    this._map.fire('enterFullscreen');

    // move the buttons
    $(".zoom_in,.zoom_out,.zoom_fs").css("position", "fixed");
    $(".zoom_in").css("top", "8px");
    $(".zoom_out").css("top", "39px");
    $(".zoom_fs").css("top", "70px");

  };
 ZoomFullscreen.prototype._exitFullScreen = function(){
    var container = this._map._container;

    // update state
    L.DomUtil.removeClass(container, 'leaflet-fullscreen');
    this._isFullscreen = false;

    // remove fullscreen style; make sure we're still position relative for Leaflet core.
    container.removeAttribute('style');

    // re-apply position:relative; if user does not have it.
    var position = L.DomUtil.getStyle(container, 'position');
    if (position !== 'absolute' && position !== 'relative') {
     container.style.position = 'relative';
    }

    //
    $(".zoom_in,.zoom_out,.zoom_fs").css("position", "absolute");
    $(".zoom_in").css("top", "-13px");
    $(".zoom_out").css("top", "15px");
    $(".zoom_fs").css("top", "43px");


    // remove ESC listener
	  L.DomEvent.removeListener(document, 'keyup', this._onKeyUp);

    // fire fullscreen event
    this._map.fire('exitFullscreen');
  };
 ZoomFullscreen.prototype. _onKeyUp = function(e){
    if (!e) var e = window.event;
    if (e.keyCode === 27 && this._isFullscreen === true) {
      this._exitFullScreen();
    }
  }



/**
 * javascript version of NameUsage.getCanonicalOrScientificName()
 */
function canonicalOrScientificName(usage) {
  if (usage.canonicalName) {
    return usage.canonicalName;
  }
  return usage.scientificName;
}


/**
 * javascript version to query the registry and get the dataset for a given uuid key.
 * The passed function will be called when the data returns.
 */
function getDatasetDetail(key, func) {
  $.getJSON(cfg.wsReg+ "dataset/" + key + "?callback=?", func);
}

/**
 * Builds up a image cache url
 */
function imageCacheUrl(url, size) {
  return cfg.wsImageCache + "?url=" + encodeURIComponent(url) + "&size=" + size;
}


/**
 * Limit the size of the text to max characters.
 * If the size of the text is greater than max, the size is limited to that max and and ellipse is added to the end.
 */
function limitText(text, max) {
  var newLabel = text;
  if(newLabel.length >= max){
    newLabel = newLabel.slice(0,max) + "…";
  }
  return newLabel;
}
