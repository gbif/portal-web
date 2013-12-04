var CONFIG = { // global config var
  minZoom: 0,
  maxZoom: 14,
  center: [0, 0],
  defaultZoom: 1
};

$(function() {
var // see http://maps.cloudmade.com/editor for the styles - 69341 is named GBIF Original
    cmAttr = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade',
    cmUrl  = 'http://{s}.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/{styleId}/256/{z}/{x}/{y}.png';

var
gbifAttrib = 'GBIF contributors',
gbif       = new L.TileLayer(gbifUrl, { minZoom: CONFIG.minZoom, maxZoom: CONFIG.maxZoom , attribution: gbifAttrib }),
minimal   = L.tileLayer(cmUrl, {styleId: 997,   attribution: cmAttr});

var map = L.map('map', {
  center: CONFIG.center,
  zoom: CONFIG.defaultZoom,
  layers: [minimal, gbif],
  zoomControl: false
});

setupZoom(map);
});