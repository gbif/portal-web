<#-- @ftlvariable name="" type="org.gbif.portal.action.dataset.StatsAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/occ_metrics.ftl" as ftlm>
<html>
<head>
  <title>${dataset.title} - Metrics</title>
  <#assign numUsages = metrics.usagesCount!0 />
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
  <content tag="extra_scripts">
    <script type="text/javascript" src="<@s.url value='/js/metrics.js'/>"></script>
    <script type="text/javascript" charset="utf-8">
        $(function() {
        <#-- OCCURRENCE -->
        <#if numOccurrences! gt 0>
          $('table.metrics').occMetrics();
          // basics
          $("#occkingdoms").setupPie(${numOccurrences?c});
          $("#bor").setupPie(${numOccurrences?c});
          $("#types").setupPie(${numOccurrences?c});
          $("#issues").setupPie(${numOccurrences?c});
        </#if>

        <#-- CHECKLIST -->
        <#if numUsages! gt 0>
          var total = ${numUsages?c};
          console.debug( "TOTAL USAGES: " + total );

          // basics
          $("#synonyms").setupPie(total);
          $("#kingdoms").setupPie(total);
          $("#ranks").setupPie(total);

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

<#-- CHECKLIST -->
<#if dataset.type! == "CHECKLIST">
  <#-- Do we have any checklist metrics and records at all? -->
  <#if numUsages! lt 1>
    <@common.article id="metrics" title="No Metrics">
      <div class="fullwidth">
          <p>We are sorry, but for this dataset there are no checklist metrics available right now.
              Please come back another time.
          </p>
      </div>
    </@common.article>
  <#else>

   <@common.article id="chkmetrics" title="Checklist Metrics">
     <div class="fullwidth">
       <ul class="pies">
           <li><h3>Synonyms</h3>
             <p>Number of synonyms and accepted taxa.</p>
             <div id="synonyms" class="pieMultiLegend">
               <ul>
                 <li><a href="<@s.url value='/species/search?dataset_key=${id}&status=accepted'/>">Accepted</a> <span class="number" data-cnt="${(numUsages - metrics.synonymsCount)?c}">${numUsages - metrics.synonymsCount}</span></li>
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
           <p>There are ${numUsages} records in the checklist. For each extension type, the total number of extension records are illustrated as the average coverage per taxon.</p>
         </div>
       </div>
    </@common.article>
    </#if>
  </#if>
</#if>


<!-- OCCURRENCS -->
<!-- Do we have any checklist metrics and records at all? -->
<#if numOccurrences! lt 1>
  <@common.article id="occmetrics" title="No Metrics">
  <div class="fullwidth">
    <p>We are sorry, but for this dataset there are no occurrence metrics available.</p>
  </div>
  </@common.article>
<#else>

  <@common.article id="occmetrics" title="Occurrence Metrics">
  <div class="fullwidth">
    <ul class="pies">
      <li><h3>Kingdoms</h3>
        <#if countByKingdom?has_content>
          <div id="occkingdoms" class="pieMultiLegend">
            <ul>
              <#list countByKingdom?keys as k>
                <li><a href="<@s.url value='/occurrence/search?dataset_key=${id}&taxon_key=${k.nubUsageID()}'/>"><@s.text name="enum.kingdom.${k}"/></a> <span class="number" data-cnt="${countByKingdom(k)?c}">${countByKingdom(k)}</span></li>
              </#list>
            </ul>
          </div>
        <#else>
          <p>This dataset does not cover any kingdom.</p>
        </#if>
      </li>

      <li>
        <#if countByTypes?has_content>
          <h3>Type specimen</h3>
          <div id="types" class="pieMultiLegend">
            <ul>
              <#list countByTypes?keys as k>
                <#assign val=countByTypes(k) />
                <li><a href="<@s.url value='/occurrence/search?dataset_key=${id}&type_status=${k}'/>">${common.enumLabel(k)}</a> <span class="number" data-cnt="${val?c}">${val}</span></li>
              </#list>
            </ul>
          </div>

        <#elseif countByBor?has_content>
          <h3>Basis of record</h3>
          <div id="bor" class="pieMultiLegend">
            <ul>
              <#list countByBor?keys as k>
                <#assign val=countByBor(k) />
                <li><a href="<@s.url value='/occurrence/search?dataset_key=${id}&basis_of_record=${k}'/>">${common.enumLabel(k)}</a> <span class="number" data-cnt="${val?c}">${val}</span></li>
              </#list>
            </ul>
          </div>
        <#else>
          <p>This dataset does not publish a basis of record.</p>
        </#if>
      </li>


      <li>
        <h3>Interpretation Issues</h3>
        <#if countByIssues?has_content>
          <div id="issues" class="pieMultiLegend">
            <ul>
              <#list countByIssues?keys as k>
                <#assign val=countByIssues(k) />
                <li><a href="<@s.url value='/occurrence/search?dataset_key=${id}&issue=${k}'/>">${common.enumLabel(k)}</a> <span class="number" data-cnt="${val?c}">${val}</span></li>
              </#list>
            </ul>
          </div>
        <#else>
          <p>This dataset does not have any issue.</p>
        </#if>
      </li>
    </ul>
  </div>

</@common.article>

  <@common.article id="occtable" title="Basis of record by Kingdom">
  <div class="fullwidth">
    <p>
      <@ftlm.metricsTable baseAddress="datasetKey=${id}"/>
    </p>
  </div>
</@common.article>
</#if>

</body>
</html>
