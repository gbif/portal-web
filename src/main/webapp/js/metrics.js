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
    $(this).find('td.total div').each(function() {
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
      $(target).html(data);
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
    });
  }
}
