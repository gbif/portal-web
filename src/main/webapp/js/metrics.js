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
    var query = "?" + baseAddress;

    if ($target.closest("tr").attr("data-kingdom") != null) {
      query += "&taxonKey=" + $target.closest("tr").attr("data-kingdom");
    }

    if ($target.hasClass("geo")) {
      query += "&isGeoreferenced=true";
    }
    var ws = cfg.wsMetrics + 'occurrence/count';

    if ($target.closest("td").attr("data-bor") === "OBSERVATION") {
      var observationTypes = ["OBSERVATION", "HUMAN_OBSERVATION", "MACHINE_OBSERVATION"];
      for (var i in observationTypes) {
        // Proxy query variable to avoid concatenating more basisOfRecord.
        var queryMod = query + "&basisOfRecord=" + observationTypes[i];
        $.getJSON(ws + queryMod + '&callback=?', function (data) {
          incrementCount($target, data);
        });
      }
    }
    else {
      if ($target.closest("td").attr("data-bor") != null) {
        query += "&basisOfRecord=" + $target.closest("td").attr("data-bor");
      }
      $.getJSON(ws + query + '&callback=?', function (data) {
        $(target).html(data);
        if (nest && data != 0) {
          // load the rest of the row
          $target.closest('tr').find('div').each(function () {
            _refresh(baseAddress, $(this), false);
          });
        }
        else if (nest) {
          // set the rest of the row to 0
          $target.closest('tr').find('div').each(function () {
            $(this).html("0");
          });
        }
      });
    }

    function incrementCount(target, value) {
      // It could be that the innerHTML value hasn't been set yet. If so, we assume zero.
      if (target.html() === "-") target.html(0);
      target.html(Number(target.html()) + Number(value));
    }
  }
};
