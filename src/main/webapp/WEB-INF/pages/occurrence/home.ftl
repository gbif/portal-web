<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Occurrence search</title>
   <content tag="extra_scripts">
      <#-- 
        Maps are embedded as iframes, but we register event listeners to link through to the occurrence
        search based on the state of the widget.
      -->
      <script type="text/javascript" src="${cfg.tileServerBaseUrl!}/map-events.js"></script>
      <script>    
        $(document).ready(function() {
          var yearsValues = new Array();  
          <#assign yearCounts=action.yearCounts>  
          <#list yearCounts?keys as k>
            yearsValues.push(${yearCounts.get(k)?c});
          </#list>                     
          $("#yearChart").addGraph(yearsValues, {height:240});
          
          new GBIFMapListener().subscribe(function(id, searchUrl) {
            $("#geoOccurrenceSearch").attr("href", "<@s.url value='/occurrence/search'/>?" +  searchUrl);
          });
        });     

     </script>
   </content>
</head>

<body class="infobandless">

<@common.article class="search_home">
    <h1>Explore <a href="<@s.url value='/occurrence/search'/>" title="">${numOccurrences!0}</a> occurrences</h1>
    <p>Occurrence records document evidence of a named organism in nature.
    Through this portal, you can <a href="<@s.url value='/occurrence/search'/>" title=""><strong>search</strong>, <strong>view</strong> and <strong>download</strong></a> records that are published through the GBIF network.
    </p>

    <div class="results">
      <ul>
        <li><a href="<@s.url value='/occurrence/search'/>" title="">${numOccurrences!0}</a>occurrences records</li>
        <li class="last"><a href="<@s.url value='/occurrence/search?GEOREFERENCED=true&SPATIAL_ISSUES=false'/>" title="">${numGeoreferenced!0}</a>georeferenced records</li>
      </ul>
    </div>
</@common.article>

<@common.article titleRight='Georeferenced data' class="map">
    <div id="map" class="map">
      <iframe id="mapByFrame" name="map" src="${cfg.tileServerBaseUrl!}/index.html?type=ALL&resolution=1&style=dark" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>
    </div>
    <div class="right">
       <div class="inner">
         <h3>View records</h3>
         <p>
           <a href="<@s.url value='/occurrence/search?GEOREFERENCED=true&SPATIAL_ISSUES=false'/>">All records</a>
           |
           <a href="<@s.url value='/occurrence/search'/>" id='geoOccurrenceSearch'>In viewable area</a></li>
         </p>
         <h3>About</h3>
         <p>
           This map shows the density of all ${numGeoreferenced!0} georeferenced occurrence records published through the GBIF network.
         </p>
         <p> 
           To explore the records, zoom into the map or click on the links above and add further filters to customize search results. 
         </p>
         
       </div>
    </div>
  </@common.article>

<@common.article title="Taxonomic characteristics">
    <div class="fullwidth">
      <p>The following provides a summary of number of records per kingdom.  Further filters, such as a location or temporal filter, may be applied when <a href="<@s.url value='/occurrence/search'/>" title="">exploring the data</a>.</p>
      <ul class="summary no_bullets">
        <#list kingdomCounts?keys as k>
          <#if kingdomCounts.get(k) gt 0>
            <li class="no_bullets">
            <div class="light_box">
              <h3><a href="<@s.url value='/occurrence/search?TAXON_KEY='/>${action.getKingdomNubUsageId(k)}">${(kingdomCounts.get(k)!0)}</a></h3>
              <div><span class="number" data-cnt="${(kingdomCounts.get(k)!0)?c}">(${(kingdomCounts.get(k) * 100 / numOccurrences)?string("0.####")}%)</span></div>
              <br/>
              <h4><@s.text name="enum.kingdom.${k}"/> records <br/> <br/> </h4>
            </div>
            </li>
          </#if>
        </#list>
      </ul>
    </div>
</@common.article>

<@common.article title="Record type characteristics">
    <div class="fullwidth">
      <p>Records may originate from a variety of means, such as a scientist collecting a specimen or an individual recording the sighting of an organism.  This is classified by the <a target="_blank" href="http://rs.tdwg.org/dwc/terms/#basisOfRecord">Darwin Core basisOfRecord</a> standard.</p>
      <ul class="summary no_bullets">
        <#assign bofCounts=action.basisOfRecordCounts>
        <#assign bofCountsTotal=0>
        <#if bofCounts?has_content>
          <#list bofCounts?keys as k>
            <#if bofCounts.get(k) gt 0>
              <li class="no_bullets">
              <div class="light_box">
                <h3><a href="<@s.url value='/occurrence/search?BASIS_OF_RECORD='/>${k}">${(bofCounts.get(k)!0)}</a></h3>
                <div><span class="number" data-cnt="${(bofCounts.get(k)!0)?c}">(${(bofCounts.get(k) * 100 / numOccurrences)?string("0.###")}%)</span></div>
                <br/>
                <h4><@s.text name="enum.basisofrecord.${k}"/> records <br/> <br/> </h4>
              </div>
              </li>
            </#if>
          </#list>
        </#if>
      </ul>
    </div>
</@common.article>

<@common.article title="Temporal characteristics" class="temporal_graph">
    <div class="left">
      <div id="yearChart" class="graph">
        <div class="start">${minYear?c}</div> <div class="end">${maxYear?c}</div>
      </div>
    </div>
    <div class="right">
      <p>This visualization shows the growth in occurrences recorded <a href="<@s.url value='/occurrence/search?YEAR=1950%2C*'/>">after 1950</a>.
      GBIF provides access to many older records, and you can add date range filters to search content for any period.</p>
      <p>For example, <a href="<@s.url value='/occurrence/search?YEAR=1850%2C1950'/>">here is a filtered view</a> for records between 1850 and 1950.</p>
    </div>
</@common.article>

</body>
</html>
