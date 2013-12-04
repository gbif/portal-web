$(window).ready(function() {
/*
    Bind the divs to load on AJAX calls.
    For performance, we first determine which kingdoms have content, then load them all

    An optional table attribute data-address is used to define additional filters
*/
  $('table.metrics').each(function() {
      var baseAddress = $(this).attr("data-address");
      //console.debug(baseAddress);
      $(this).find('td.total div').each(function() {
        refresh(baseAddress, $(this), true);
      });
  });

  function refresh(baseAddress, target, nest) {
    var $target = $(target);

    // always add the datasetKey to the cube address
    var address = "?" + baseAddress;

    if ($target.closest("tr").attr("data-kingdom") != null) {
      address = address + "&nubKey=" + $target.closest("tr").attr("data-kingdom");
    }

    if ($target.closest("td").attr("data-bor") != null) {
      address = address + "&basisOfRecord=" + $target.closest("td").attr("data-bor");
    }

    if ($target.hasClass("geo")) {
      address = address + "&georeferenced=true";
    }
    var ws = cfg.wsMetrics + 'occurrence/count' + address;
    //console.debug(ws);
    $.getJSON(ws + '&callback=?', function (data) {
      $(target).html(data);
      if (nest && data!=0) {
        // load the rest of the row
        $target.closest('tr').find('div').each(function() {
          refresh(baseAddress, $(this), false);
        });
      } else if (nest) {
        // set the rest of the row to 0
        $target.closest('tr').find('div').each(function() {
          $(this).html("0");
        });
      }
    });
  }
});
