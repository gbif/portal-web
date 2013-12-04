<html>
<head>
  <title>${dataset.title} - Metrics</title>
  <#assign total = metrics.usagesCount />
  <content tag="extra_scripts">
    <script type="text/javascript" charset="utf-8">
        $(function() {
          <#if total! gt 0>
              var total = ${total?c};
              console.debug( "TOTAL: " + total );

              function setupPie(legend) {
                var pieId = legend.attr("id") + "pie";
                $(legend).before("<div id='" +pieId+ "' class='multipie'></div>");
                var values = [];
                $("li span.number", legend).each(function() {
                    values.push( Math.round($(this).attr("data-cnt") * 100 / total))
                });
                console.debug(pieId + ": " + values);
                $("#"+pieId).bindMultiPie(36.5, values);
                $(legend).addMultiLegend();
              }

              // basics
              setupPie($("#synonyms"));
              setupPie($("#kingdoms"));
              setupPie($("#ranks"));

              // overlap
              $("#pieNub").bindPie(36.5, Math.floor(${metrics.nubCoveragePct}));
              $("#pieCol").bindPie(36.5, Math.floor(${metrics.colCoveragePct}));

              // vernaculars & extensions
              <#list metrics.countExtRecordsByExtension?keys as ext>
                <#assign count = metrics.getExtensionRecordCount(ext) />
                <#if count gt 0>
                  $("#extensions").append("<p><div id='pieExt${ext_index}'></div></p>");
                  $("#pieExt${ext_index}").bindLabelPie(36, Math.floor(${count?c} / total * 100), '<@s.text name="enum.extension.${ext}"/>', "${count}", 16);
                </#if>
              </#list>

            <#if metrics.countNamesByLanguage?has_content>
              <#-- assumes they are sorted by size -->
              var maxVernacular = ${metrics.countNamesByLanguage?values[0]?c};
              console.debug("maxVernacular: " + maxVernacular);
              // max 400px
              $("#vernacular_graph").bindGreyBars( (400-((maxVernacular+"").length)*10) / maxVernacular);
            </#if>

          </#if>
        });
    </script>
  </content>
</head>
<body>
  <#-- Set up the tabs to highlight the info tab, and includ a backlink -->
  <#assign tab="stats"/>
  <#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

<!-- Do we have any metrics and records at all? -->
<#if total! lt 1>
  <@common.article id="metrics" title="No Metrics">
    <div class="fullwidth">
        <p>We are sorry, but for this dataset there are no metrics available right now.
            Please come back another time.
        </p>
    </div>
  </@common.article>
<#else>

<@common.article id="metrics" title="Core Metrics">
   <div class="fullwidth">
     <ul class="pies">
         <li><h3>Synonyms</h3>
           <p>Number of synonyms and accepted taxa.</p>
           <div id="synonyms" class="pieMultiLegend">
             <ul>
               <li><a href="<@s.url value='/species/search?dataset_key=${id}&status=accepted'/>">Accepted</a> <span class="number" data-cnt="${(total - metrics.synonymsCount)?c}">${total - metrics.synonymsCount}</span></li>
               <li><a href="<@s.url value='/species/search?dataset_key=${id}&status=synonym'/>">Synonyms</a> <span class="number" data-cnt="${metrics.synonymsCount?c}">${metrics.synonymsCount}</span></li>
             </ul>
           </div>
         </li>

       <li><h3>Kingdoms</h3>
         <#if metrics.countByKingdom?has_content>
           <p>Number of name usages within kingdoms of the GBIF Backbone.</p>
           <div id="kingdoms" class="pieMultiLegend">
             <ul>
             <#list kingdoms as k>
               <#if metrics.countByKingdom(k)?has_content>
                 <li><a href="#"><@s.text name="enum.kingdom.${k}"/></a> <span class="number" data-cnt="${(metrics.countByKingdom(k)!0)?c}">${metrics.countByKingdom(k)!0}</span></li>
               </#if>
             </#list>
             </ul>
           </div>
         <#else>
          <p>This dataset does not include any kingdom information.</p>
         </#if>
       </li>


       <li><h3>Ranks</h3>
         <#if metrics.countByRank?has_content>
           <p>Number of accepted taxa by major ranks.</p>
           <div id="ranks" class="pieMultiLegend">
             <ul>
               <#list sortedMetricRanks as r>
                 <#if metrics.countByRank(r) gt 0>
                 <#assign cnt = metrics.countByRank(r)!0 />
                   <li><a href="<@s.url value='/species/search?dataset_key=${id}&rank=${r}'/>"><@s.text name="enum.rank.${r}"/> <span class="number" data-cnt="${cnt?c}">${cnt}</span></a></li>
                 </#if>
               </#list>
             </ul>
           </div>
         <#else>
          <p>This dataset does not include any rank information.</p>
         </#if>
       </li>
     </ul>
   </div>

 </@common.article>

 <@common.article id="overlap" title="Checklist Overlap" titleRight="Names">
<div class="left">
    <ul class="pies">
       <li><h3>GBIF BACKBONE</h3>
         <p>Percentage of name usages also found in the <a href="<@s.url value='/dataset/${nubKey}'/>">GBIF Backbone</a>.</p>
         <div id="pieNub"></div>
       </li>
       <li class="last"><h3>CATALOGUE OF LIFE</h3>
         <p>Percentage of name usages also found in the <a href="<@s.url value='/dataset/${colKey}'/>">Catalogue of Life</a>.</p>
         <div id="pieCol"></div>
       </li>
     </ul>
</div>
<div class="right">
  <h3>UNIQUE NAMES</h3>
  <p>There are ${metrics.distinctNamesCount} unique names in this dataset.
  <#if metrics.distinctNamesCount gt 0>
    On average ${100 * (metrics.usagesCount - metrics.distinctNamesCount) / metrics.distinctNamesCount}%
    of the names are found in more than one taxon.
  </#if>
  </p>
</div>

</@common.article>

  <#if metrics.countNamesByLanguage?has_content>
  <@common.article id="vernaculars" title="Vernacular Name Languages" titleRight="Extension Data">
      <div id="vernacular_graph" class="left">
        <#assign langs = metrics.countNamesByLanguage?keys>
        <ul class="no_bullets horizontal_graph">
        <#list langs as l>
          <li><a href="#">
          <#if "UNKNOWN"==l>Unknown<#else>${l.getTitleEnglish()}</#if>
          </a> <div class="grey_bar">${(metrics.countNamesByLanguage(l)!0)?c}</div></li>
        </#list>
         </ul>
       </div>

       <div id="extensions" class="right">
         <p>There are ${total} records in the checklist. For each extension type, the total number of extension records are illustrated as the average coverage per taxon.</p>
       </div>
     </div>
  </@common.article>
  </#if>


</#if>

</body>
</html>
