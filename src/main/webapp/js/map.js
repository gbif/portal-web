// The map layers can be controlled
var LAYER_OBSERVATION = ["OBS_NO_YEAR","OBS_PRE_1900","OBS_1900_1910","OBS_1910_1920","OBS_1920_1930","OBS_1930_1940","OBS_1940_1950","OBS_1950_1960","OBS_1960_1970","OBS_1970_1980","OBS_1980_1990","OBS_1990_2000","OBS_2000_2010","OBS_2010_2020"];
var LAYER_LIVING = ["LIVING"];
var LAYER_FOSSIL = ["FOSSIL"];
var LAYER_SPECIMEN = ["SP_NO_YEAR","SP_PRE_1900","SP_1900_1910","SP_1910_1920","SP_1920_1930","SP_1930_1940","SP_1940_1950","SP_1950_1960","SP_1960_1970","SP_1970_1980","SP_1980_1990","SP_1990_2000","SP_2000_2010","SP_2010_2020"];
var LAYER_OTHER = ["OTH_NO_YEAR","OTH_PRE_1900","OTH_1900_1910","OTH_1910_1920","OTH_1920_1930","OTH_1930_1940","OTH_1940_1950","OTH_1950_1960","OTH_1960_1970","OTH_1970_1980","OTH_1980_1990","OTH_1990_2000","OTH_2000_2010","OTH_2010_2020"];
var LAYER_ALL = [
  "OBS_NO_YEAR","OBS_PRE_1900","OBS_1900_1910","OBS_1910_1920","OBS_1920_1930","OBS_1930_1940","OBS_1940_1950","OBS_1950_1960","OBS_1960_1970","OBS_1970_1980","OBS_1980_1990","OBS_1990_2000","OBS_2000_2010","OBS_2010_2020",
  "LIVING",
  "FOSSIL",
  "SP_NO_YEAR","SP_PRE_1900","SP_1900_1910","SP_1910_1920","SP_1920_1930","SP_1930_1940","SP_1940_1950","SP_1950_1960","SP_1960_1970","SP_1970_1980","SP_1980_1990","SP_1990_2000","SP_2000_2010","SP_2010_2020",
  "OTH_NO_YEAR","OTH_PRE_1900","OTH_1900_1910","OTH_1910_1920","OTH_1920_1930","OTH_1930_1940","OTH_1940_1950","OTH_1950_1960","OTH_1960_1970","OTH_1970_1980","OTH_1980_1990","OTH_1990_2000","OTH_2000_2010","OTH_2010_2020"  
];


$.fn.densityMap = function(key, type, options) {
  this.occurrenceMap(this.attr("id"), $.extend({type: type, key: key, defaultZoom: 1}, options));
}

$.fn.pointMap = function(lat, lng, options) {
  this.occurrenceMap(this.attr("id"), $.extend({type: "point", marker: [lat,lng], defaultZoom: 10, center:[lat,lng]}, options));
}

// Expose method to create an occurrence map
// accepts density or point as the map type, defaulting to a density map
$.fn.occurrenceMap = function(id, options) {
  var settings = $.extend({
      minZoom: 0,
      maxZoom: 14,
      center: [0, 0],
      defaultZoom: 1,
      marker: [0, 0],
      bboxes: [],  // bounding boxes that can optionally be shown, e.g. eml dataset coverage
      key: "", // value used for filtering layers
      type: "point"  // "point", otherwise used as the density layer type
    }, options
  );

  var 
  cmAttr = 'Nokia',
  cmUrl  = 'http://2.maps.nlp.nokia.com/maptile/2.1/maptile/newest/normal.day.grey/{z}/{x}/{y}/256/png8?app_id=_peU-uCkp-j8ovkzFGNU&app_code=gBoUkAMoxoqIWfxWA5DuMQ';

  var
  gbifBase  = L.tileLayer(cmUrl, {styleId: 69341, attribution: cmAttr}),
  minimal   = L.tileLayer(cmUrl, {styleId: 997,   attribution: cmAttr}),
  midnight  = L.tileLayer(cmUrl, {styleId: 999,   attribution: cmAttr});

  // window scrolling needs to be disabled on full screan maps
  // but we need to return it on exiting
  var scrollPosition;

  var baseLayers = {
    "Classic":    gbifBase,
    "Minimal":    minimal,
    "Night View": midnight
  };

  var overlays = {
  };

  var map = L.map(id, {
    center: settings.center,
    zoom: settings.defaultZoom,
    layers: [minimal],
    zoomControl: false
  });


  if (options.type == "point") {
    _initPointMap();

  } else {
    _initDensityMap(settings.key, settings.type);
  }

  _addBboxes(settings.bboxes);

  setupZoom(map);

  // points (like occurrence detail) have no styling changes
  if (options.type != "point") {
    L.control.layers(baseLayers, overlays).addTo(map);
  }
  

  // entering fullscreen disables the window scrolling
  map.on('enterFullscreen', function(){
    scrollPosition = [
      self.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft,
      self.pageYOffset || document.documentElement.scrollTop  || document.body.scrollTop
    ];
    var html = jQuery('html'); // it would make more sense to apply this to body, but IE7 won't have that
    html.data('scroll-position', scrollPosition);
    html.data('previous-overflow', html.css('overflow'));
    html.css('overflow', 'hidden');
    window.scrollTo(scrollPosition[0], scrollPosition[1]);
  });

  // enable the window scrolling exiting fullscreen
  map.on('exitFullscreen', function(){
    var html = jQuery('html');
    var scrollPosition = html.data('scroll-position');
    html.css('overflow', html.data('previous-overflow'));
    window.scrollTo(scrollPosition[0], scrollPosition[1]);
  });

  // builds the layer parameters from the input array
  function _buildLayer(layers) {
    var s="";
    $.each(layers, function() {
      s += "&layer=" + this;
    });
    return s;
  }

  function _initDensityMap(key, type) {
    var
    gbifUrl    = cfg.tileServerBaseUrl + '/density/tile?resolution=4&key=' + key + '&x={x}&y={y}&z={z}&type=' + type,
    l_all    = gbifUrl+ _buildLayer(LAYER_ALL) + "&palette=yellow_reds",
    l_obs    = gbifUrl+ _buildLayer(LAYER_OBSERVATION)  + "&palette=blues",
    l_liv    = gbifUrl+ _buildLayer(LAYER_LIVING)  + "&palette=greens",
    l_fos    = gbifUrl+ _buildLayer(LAYER_FOSSIL)  + "&palette=purples",
    l_spe    = gbifUrl+ _buildLayer(LAYER_SPECIMEN)  + "&palette=reds",
    l_oth    = gbifUrl+ _buildLayer(LAYER_OTHER)  + "&palette=orange",
    gbifAttrib = 'GBIF contributors',
    gbifAll       = new L.TileLayer(l_all, { minZoom: settings.minZoom, maxZoom: settings.maxZoom , attribution: gbifAttrib }),
    gbifObs       = new L.TileLayer(l_obs, { minZoom: settings.minZoom, maxZoom: settings.maxZoom , attribution: gbifAttrib }),
    gbifLiv       = new L.TileLayer(l_liv, { minZoom: settings.minZoom, maxZoom: settings.maxZoom , attribution: gbifAttrib }),
    gbifFos       = new L.TileLayer(l_fos, { minZoom: settings.minZoom, maxZoom: settings.maxZoom , attribution: gbifAttrib }),
    gbifSpe       = new L.TileLayer(l_spe, { minZoom: settings.minZoom, maxZoom: settings.maxZoom , attribution: gbifAttrib }),
    gbifOth       = new L.TileLayer(l_oth, { minZoom: settings.minZoom, maxZoom: settings.maxZoom , attribution: gbifAttrib });

    overlays = {
      "All types": gbifAll,
      "Preserved specimens": gbifSpe,
      "Observations": gbifObs,
      "Living specimens": gbifLiv,
      "Fossils": gbifFos,
      "Other types": gbifOth
     };

    map.addLayer(gbifAll);

    $(".tileControl").on("click", function(e) {
      e.preventDefault();
      if ($(this).attr("data-action") == 'show-specimens') {
        gbifUrl = cfg.tileServerBaseUrl + '/density/tile?key=' + key + '&x={x}&y={y}&z={z}&type=' + type
        + _buildLayer(LAYER_SPECIMEN);

      } else if ($(this).attr("data-action") == 'show-observations') {
        gbifUrl = cfg.tileServerBaseUrl + '/density/tile?key=' + key + '&x={x}&y={y}&z={z}&type=' + type
        + _buildLayer(LAYER_OBSERVATION);

      } else if ($(this).attr("data-action") == 'show-all') {
        gbifUrl = cfg.tileServerBaseUrl + '/density/tile?key=' + key + '&x={x}&y={y}&z={z}&type=' + type
        + _buildLayer(LAYER_ALL);

      }
      gbif.setUrl(gbifUrl);
    });

    // modify the "view all records in visibile area" with the bounds of the map
    $('.viewableAreaLink').bind('click', function(e) {
      var target = $(this).attr("href");
      var bounds=map.getBounds();
      var sw=bounds.getSouthWest(); // south west
      var ne=bounds.getNorthEast();
      var se=bounds.getSouthEast();
      var nw=bounds.getNorthWest();
      
      var separator = target.indexOf('?') !== -1 ? "&" : "?";
      
      // limit bounds or SOLR barfs
      sw.lng = sw.lng<-180 ? -180 : sw.lng;
      sw.lat = sw.lat<-90 ? -90 : sw.lat;
      nw.lng = nw.lng<-180 ? -180 : nw.lng;
      nw.lat = nw.lat>90 ? 90 : nw.lat;
      ne.lng = ne.lng>180 ? 180 : ne.lng;
      ne.lat = ne.lat>90 ? 90 : ne.lat;
      se.lng = se.lng>180 ? 180 : se.lng;
      se.lat = se.lat<-90 ? -90 : se.lat;  
      
      // records on maps are those with no issues
      $(this).attr("href", target + separator + "SPATIAL_ISSUES=false&GEOMETRY="
        + sw.lng + " " + sw.lat + ","
        + nw.lng + " " + nw.lat + ","
        + ne.lng + " " + ne.lat + ","
        + se.lng + " " + se.lat + ","
        + sw.lng + " " + sw.lat);
    });
  }

  function _initPointMap() {
    L.marker(settings.marker).addTo(map);
    map.setView(settings.marker, 10);
  }

  function _addBboxes(bboxes) {
    // draw the bounding boxes should they exist (for example from a geographic coverage in the dataset)
    if (typeof bboxes !== "undefined") {
      // bboxes have minLat,maxLat,minLng,maxLng
      $.each(bboxes, function(index, box) {
        // handle boxes that are really points
        if (box[0]==box[1] && box[2]==box[3]) {
        L.marker([box[0], box[2]]).addTo(map);
        } else {
        var bounds = [[box[0], box[2]], [box[1], box[3]]];
          L.rectangle(bounds, {color: "#ff7800", weight: 2}).addTo(map);
          // Some small boxes don't show, so provide a marker
          L.marker([box[0] + ((box[1]-box[0])/2), box[2] + ((box[3]-box[2])/2)]).addTo(map);
        }
      });
    }
  }

}
