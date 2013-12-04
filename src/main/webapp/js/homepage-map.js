/**
 * Provides the homepage map functionality only.
 * Requires JQuery, leaflet and the standard cfg object.
 */
$(function() {
  var maxVisible = 300; // at any time
  var delayMsecs = 1000;
  
  // increment a seed to force randomization and avoid per client caches 
  var seed=0; 
      
  // randomize the initial view port location a little, but not too much 
  var startLat = Math.floor(Math.random()*30); 
  var startLng = Math.floor(Math.random()*90) - 45; 
  
  var map = L.map('homepageMap', {
    center: [startLng, startLat],
    zoom: 2,
    minZoom: 1,
    touchZoom: false,
    scrollWheelZoom: false,
    doubleClickZoom: false
  });  
  
  L.tileLayer('../img/tiles/{z}/{x}/{y}.png', {
    maxZoom: 4,
    minZoom: 0,
  }).addTo(map);
  
  var points = [];  
  var visible = []; // at any time
  
  function initData() {
    for (var i=0;i<maxVisible;i++) {
    points.push(
      new L.CircleMarker([0, 0], {
      fillColor: '#223E1D',
      weight: 2,
      color: '#FFF',
      fillOpacity: 1, 
      opacity: 0.8,
      radius: 4,
    }));
    }
  }
  
  /**
   * Gets a page of occurrences from the server
   */
  function getOccurrences() {
    var occurrences = [];
    $.ajax({
      url: cfg.wsOcc + 'occurrence/featured?seed='+seed++,
      success: function(data) {
    $.each(data, function(index, o) {
      occurrences.push(o);
    });
      }, async:false});        
    occurrences.reverse; // so we can just pop off the end
    return occurrences;
  }
  
  var currentPointIdx=0;
  var occurrences = getOccurrences();
  
  /**
   * Gets a batch from the server and pages through it plotting the points
   */
  function runMap() {
    // get a batch from the server
    if (occurrences.length==0) {
      occurrences = getOccurrences();
    }
  	  	
  	var point = points[currentPointIdx];
  	if(point._map && point._map.hasLayer(point._popup)) {
  	  // popup is open, can't remove this point
    } else {
  	  var occurrence = occurrences.pop();
    	if (occurrence!==undefined) {
      	point.setLatLng([occurrence.latitude,occurrence.longitude]);
      	point.unbindPopup(); // avoid memory leak
      	point.bindPopup(
          "<p>Occurrence of <a href='occurrence/" + occurrence.key + "'>" + occurrence.scientificName +"</a></p>" +
          "Published by <a href='publisher/" + occurrence.publisherKey + "'>" + occurrence.publisher +"</a>" +
          "<p>Last indexed " + moment(occurrence.modified).fromNow() +"</p>");         
      	point.addTo(map); // it should already be
    	
    	}
    }  	
    
  	// move to next one
  	currentPointIdx = currentPointIdx + 1;
  	// reuse the points
  	if (currentPointIdx >= points.length) {
  	  currentPointIdx = 0;
  	}
  	
    setTimeout(runMap, delayMsecs);
  }
  initData();
  runMap();
});