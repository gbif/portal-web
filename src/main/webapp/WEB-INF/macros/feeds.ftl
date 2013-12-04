<#macro googleFeedJs url target>
  var tmplG = $("#tmpl-rss-google").html();
  // we use google feed API to read external cross domain feeds
  $.getJSON( 'http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&output=json&q=${url}&hl=en&callback=?', function( resp ) {
    $("${target}").html( _.template(tmplG, {feed:resp.responseData.feed}) );
    $("${target} .date").each(function(i) {
      var md = moment($(this).text());
      $(this).text(md.fromNow());
    });
  });
</#macro>

<#macro drupalTagFeedJs tagId target>
  var tmplD = $("#tmpl-tag-drupal").html();
  $.getJSON( '${cfg.drupal}/tags/id/${tagId}?callback=?', function( resp ) {
    $("${target}").html( _.template(tmplD, {feed:resp}) );
  });
</#macro>

<#macro drupalFeaturedDatasetJs target>
  $("${target}").hide();
  var tmplD = $("#tmpl-datasets-drupal").html();
  $.getJSON( '${cfg.drupal}/featureddatasets/json?callback=?', function( resp ) {
    if (!_.isEmpty(resp.nodes) ) {
      $("${target}").html( _.template(tmplD, {feed:resp}) );
      $("${target}").show();
    };
  });
</#macro>

<#macro mendeleyFeedJs isoCode target>
  var tmplM = $("#tmpl-mendeley-publications").html();
  $.getJSON( '${cfg.drupal}/mendeley/country/${isoCode}/json?callback=?', function(data){
    if (data.length > 0) {
      $("${target}").html( _.template(tmplM, {feed:data}) );
    }
  });
</#macro>
