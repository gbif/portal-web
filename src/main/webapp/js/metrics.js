$.fn.setupPie = function(total){
  var pieId = this.attr("id") + "pie";
  $(this).before("<div id='" +pieId+ "' class='multipie'></div>");
  var values = [];
  $("li span.number", this).each(function() {
    values.push( Math.round($(this).attr("data-cnt") * 100 / total))
  });
  $("#"+pieId).bindMultiPie(36.5, values);
  $(this).addMultiLegend();
}



/*
 Usage:
 $('table.metrics').occMetrics();

 Bind the divs to load on AJAX calls.
 For performance, we first determine which kingdoms have content, then load them all

 An optional table attribute data-address is used to define additional filters
 */
$.fn.occMetrics = function(){
  this.each(function() {
    var baseAddress = $(this).attr("data-address");
    //console.debug(baseAddress);
    $(this).find('td.totalgeo div').each(function() {
      _refresh(baseAddress, $(this), true);
    });
  });

  function _refresh(baseAddress, target, nest) {
    var $target = $(target);

    // always add the datasetKey to the cube address
    var address = "?" + baseAddress;

    if ($target.closest("tr").attr("data-kingdom") != null) {
      address = address + "&taxonKey=" + $target.closest("tr").attr("data-kingdom");
    }

    if ($target.closest("td").attr("data-bor") != null) {
      address = address + "&basisOfRecord=" + $target.closest("td").attr("data-bor");
    }

    if ($target.hasClass("geo")) {
      address = address + "&isGeoreferenced=true";
    }
    var ws = cfg.wsMetrics + 'occurrence/count' + address;
    //console.debug(ws);
    $.getJSON(ws + '&callback=?', function (data) {
      // We need to add human observation and machine one to existing OBSERVATION count. See POR-2702.
      if ($target.closest("td").attr("data-bor") === "OBSERVATION") {
        var params = parseParams(ws);
        var observationTypes = ["OBSERVATION", "HUMAN_OBSERVATION", "MACHINE_OBSERVATION"];

        for (var i in observationTypes) {
          params.basisOfRecord = observationTypes[i];
          var query = constructQuery(params);
          ws = cfg.wsMetrics + "occurrence/count" + query + '&callback=?';
          $.getJSON(ws, function (data) {
            incrementCount($target, data);
          });
        }
      }
      else {
        $(target).html(data);
      }

      if (nest && data!=0) {
        // load the rest of the row
        $target.closest('tr').find('div').each(function() {
          _refresh(baseAddress, $(this), false);
        });
      } else if (nest) {
        // set the rest of the row to 0
        $target.closest('tr').find('div').each(function() {
          $(this).html("0");
        });
      }
      
      function incrementCount(target, value) {
        // It could be that the innerHTML value hasn't been set yet. If so, we assume zero.
        if (target.html() === "-") target.html(0);
        target.html(Number(target.html()) + Number(value));
      }
      
    });
  }
  
  // Utility functions for parsing URL.
  // @see http://jsfiddle.net/v92Pv/22/
  // @see https://gist.github.com/kares/956897
  // Add an URL parser to JQuery that returns an object
  // This function is meant to be used with an URL like the window.location
  // Use: $.parseParams('http://mysite.com/?var=string') or $.parseParams() to parse the window.location
  // Simple variable:  ?var=abc                        returns {var: "abc"}
  // Simple object:    ?var.length=2&var.scope=123     returns {var: {length: "2", scope: "123"}}
  // Simple array:     ?var[]=0&var[]=9                returns {var: ["0", "9"]}
  // Array with index: ?var[0]=0&var[1]=9              returns {var: ["0", "9"]}
  // Nested objects:   ?my.var.is.here=5               returns {my: {var: {is: {here: "5"}}}}
  // All together:     ?var=a&my.var[]=b&my.cookie=no  returns {var: "a", my: {var: ["b"], cookie: "no"}}
  // You just cant have an object in an array, e.g. ?var[1].test=abc DOES NOT WORK
  var re = /([^&=]+)=?([^&]*)/g;
  var decode = function (str) {
    return decodeURIComponent(str.replace(/\+/g, ' '));
  };
  function parseParams(query) {

    // recursive function to construct the result object
    function createElement(params, key, value) {
      key = key + '';

      // if the key is a property
      if (key.indexOf('.') !== -1) {
        // extract the first part with the name of the object
        var list = key.split('.');

        // the rest of the key
        var new_key = key.split(/\.(.+)?/)[1];

        // create the object if it doesnt exist
        if (!params[list[0]]) params[list[0]] = {};

        // if the key is not empty, create it in the object
        if (new_key !== '') {
          createElement(params[list[0]], new_key, value);
        } else console.warn('parseParams :: empty property in key "' + key + '"');
      }
      // if the key is an array
      else if (key.indexOf('[') !== -1) {
        // extract the array name
        var list = key.split('[');
        key = list[0];

        // extract the index of the array
        var list = list[1].split(']');
        var index = list[0]

        // if index is empty, just push the value at the end of the array
        if (index == '') {
          if (!params) params = {};
          if (!params[key] || !$.isArray(params[key])) params[key] = [];
          params[key].push(value);
        }
        // add the value at the index (must be an integer)
        else {
          if (!params) params = {};
          if (!params[key] || !$.isArray(params[key])) params[key] = [];
          params[key][parseInt(index)] = value;
        }
      }
      else
      // just normal key
      {
        if (!params) params = {};
        params[key] = value;
      }
    }

    // be sure the query is a string
    query = query + '';

    if (query === '') query = window.location + '';

    var params = {}, e;
    if (query) {
      // remove # from end of query
      if (query.indexOf('#') !== -1) {
        query = query.substr(0, query.indexOf('#'));
      }

      // remove ? at the begining of the query
      if (query.indexOf('?') !== -1) {
        query = query.substr(query.indexOf('?') + 1, query.length);
      } else return {};

      // empty parameters
      if (query == '') return {};

      // execute a createElement on every key and value
      while (e = re.exec(query)) {
        var key = decode(e[1]);
        var value = decode(e[2]);
        createElement(params, key, value);
      }
    }
    return params;
  }
  
  // Encode an object to an url string
  // This function return the search part, begining with "?"
  // Use: contructQuery({var: "test", len: 1}) returns ?var=test&len=1
  // @see http://jsfiddle.net/cADUU/4/
  function constructQuery(object) {

    // recursive function to construct the result string
    function createString(element, nest) {
      if (element === null) return '';
      if ($.isArray(element)) {
        var count = 0,
          url = '';
        for (var t = 0; t < element.length; t++) {
          if (count > 0) url += '&';
          url += nest + '[]=' + element[t];
          count++;
        }
        return url;
      }
      else if (typeof element === 'object') {
        var count = 0,
          url = '';
        for (var name in element) {
          if (element.hasOwnProperty(name)) {
            if (count > 0) url += '&';
            url += createString(element[name], nest + '.' + name);
            count++;
          }
        }
        return url;
      }
      else {
        return nest + '=' + element;
      }
    }

    var url = '?',
      count = 0;

    // execute a createString on every property of object
    for (var name in object) {
      if (object.hasOwnProperty(name)) {
        if (count > 0) url += '&';
        url += createString(object[name], name);
        count++;
      }
    }

    return url;
  }
}
