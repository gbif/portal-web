<script type="text/html" id="tmpl-taxbrowser-init">
  <div class="breadcrumb">
    <ul>
      <li spid="-1"><a href="#">All</a></li>
    </ul>
  </div>
  <div class="loadingTaxa"><img src="../img/taxbrowser-loader.gif" alt=""></div>
  <div class="inner">
    <div class="sp">
      <ul></ul>
    </div>
  </div>
</script>


<script type="text/javascript">
$.fn.taxonomicExplorer = function(datasetKey) {
  var $browser = $(this);
  $browser.html( _.template($("#tmpl-taxbrowser-init").html()) );

  var transitionSpeed=300;
  var liHeight=25;
  var $limit = 45
  var $offset=0;
  var $spid = -1; // the current species aka name usage key or false to load the root
  var $lock = false; // used to block new requests while previous ahvent returned yet
  var $loadedAllChildren=false;

  var $breadcrumb = $browser.find(".breadcrumb");
  var $loading = $browser.find(".loadingTaxa");
  var $usages = $browser.find(".sp ul");
  var $inner = $browser.find('.inner');

  // setup inner scroll pane to load more usages when we are close to the bottom
  $inner.scroll(function() {
    var triggerHeight = $usages.height() - $browser.height() - 100;
    if (!$loadedAllChildren && $inner.scrollTop() > triggerHeight){
      loadChildren(false);
    }
  });

  //create the tree with the root taxa
  loadNewUsage();

  // event binding for user clicks on a name in the list
  $( document ).on( 'click', '.sp span.sciname', function(e) {
    e.preventDefault();
    // ignore if locked
    if ($lock) {
      return;
    }
    $lock = true;

    // get the id of the taxonomic element clicked and add it to the breadcrumb
    $spid = $(this).parent().attr("spid");

    // transform the last element of the breadcrumb in a link
    var $last_li = $breadcrumb.find("li:last");
    $last_li.removeClass("last");
    $last_li.wrapInner('<a href="#"></a>');

    // format HTML that will be appended to the breadcrumb
    var $item = '<li spid="' + $spid + '" class="last" style="opacity:0;">' + $(this).text() + '</li>';
    $breadcrumb.find("ul").append($item);
    // make the new breadcrumb element appear with a slow transition
    $breadcrumb.find("li:last").animate({opacity:1}, transitionSpeed);
    //recreate the taxonomic tree
    loadNewUsage();
  });

  // event binding for user clicks on the breadcrumb
  $( document ).on( 'click', '.breadcrumb li', function(e) {
    e.preventDefault();
    // ignore if locked
    if ($lock) {
      return;
    }
    $lock = true;

    // get species id from crumb list item
    $spid = $(this).attr("spid");

    // remove all further crumbs and make this the last
    $(this).nextAll().remove();
    $(this).css("last");

    //recreate the taxonomic tree
    loadNewUsage();
  });



  function loadNewUsage() {
    //reset vars
    $offset = 0;
    $loadedAllChildren = false;
    //remove all children from tax browser
    $usages.html("");

    loadChildren();
  }

  // load current page and append or replace usages in taxonomic tree
  function loadChildren(){
    $loading.show();

    // build $url
    if ($spid < 0) {
      var $wsUrl = cfg.wsClb + "species/root/" + datasetKey;
    } else {
      var $wsUrl = cfg.wsClb + "species/" + $spid + "/children";
    }

    $.getJSON($wsUrl + "?limit=" + $limit + "&offset=" + $offset + "&callback=?", function(data) {
      $loadedAllChildren = data.endOfRecords;
      $(data.results).each(function() {
        $htmlContent = '<li spid="' + this.key + '">';
        $htmlContent += '<span class="sciname">' + canonicalOrScientificName(this) + "</span>";
        $htmlContent += '<span class="rank">' + $i18nresources.getString("enum.rank." + (this.rank || "UNKNOWN")) + "</span>";
        if (this.numDescendants>0) {
          $htmlContent += '<span class="count">' + addCommas(this.numDescendants) + " descendants</span>";
        }
        $htmlContent += '</span>';
        $htmlContent += '<a href="' + cfg.baseUrl + "/species/" + this.key + '" style="display: none; ">see details</a></li>';
        $usages.append($htmlContent);
      })
      $usages.find("li").hover(function() {
        $(this).find("a:first").show();
      }, function() {
        $(this).find("a:first").hide();
      });
      $loading.fadeOut("slow");
      $lock = false;
    });
  };

};
</script>