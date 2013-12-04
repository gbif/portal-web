<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/feeds.ftl" as feeds>
<html>
  <head>
    <title>Dataset - GBIF</title>
    <content tag="extra_scripts">
      <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-ui-1.8.17.min.js'/>"></script>
      <script type="text/javascript" src="<@s.url value='/js/portal_autocomplete.js'/>"></script>
      <script type="text/javascript">
      $(function() {
        $("#q").datasetAutosuggest(cfg.wsRegSuggest, 6, 75, "#content",function(item){ window.location = cfg.baseUrl + "/dataset/" + item.key;});
        <@feeds.drupalFeaturedDatasetJs target="#featuredDatasets" />
      });
      </script>
      <style type="text/css">
          #content article.featured footer {
              background: url("../img/boxes/box_bottom.png") no-repeat left top;
          }
      </style>
      <#include "/WEB-INF/inc/feed_templates.ftl">
    </content>
  </head>
  <body class="infobandless">


<@common.article class="search_home">
     <h1>Search ${numDatasets} datasets</h1>
     <p>
       or view the <a href="<@s.url value='/publisher/search'/>">publishing institutions</a>
     </p>

     <form action="<@s.url value='/dataset/search'/>" method="GET">
       <span class="input_text">
         <input type="text" value="" name="q" id="q" placeholder="Search for datasets by title, description, publisher..." class="focus"/>
       </span>
       <button type="submit" class="search_button"><span>Search</span></button>
     </form>
     <div class="results">
       <ul>
         <li><a href="<@s.url value='/dataset/search?type=OCCURRENCE'/>">${numOccurrenceDatasets}</a>occurrences datasets</li>
         <li class="last"><a href="<@s.url value='/dataset/search?type=CHECKLIST'/>">${numChecklistDatasets}</a>checklists</li>
         <#--
           http://dev.gbif.org/issues/browse/PF-1141
           Removed while GBIF do not actually index much metadata - this raises question unnecessarily as it is so prominent
           <li class="last"><a href="<@s.url value='/dataset/search?type=METADATA'/>">${numMetadataDatasets}</a>metadata-only datasets</li>
         #-->
       </ul>
     </div>
 </@common.article>


<@common.article id="featured" title="Featured datasets" class="featured">
  <div id="featuredDatasets" class="inner"></div>
</@common.article>


  </body>
</html>
