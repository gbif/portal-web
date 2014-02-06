<#-- @ftlvariable name="" type="org.gbif.portal.action.dataset.StatsAction" -->
<#import "/WEB-INF/macros/occ_metrics.ftl" as metrics>
<html>
<head>
  <title>${dataset.title} - Metrics</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
  <content tag="extra_scripts">
    <script type="text/javascript" src="<@s.url value='/js/metrics.js'/>"></script>
    <script type="text/javascript" charset="utf-8">
      $(function() {
        $('table.metrics').occMetrics();
<#if numOccurrences! gt 0>
        // basics
        $("#kingdoms").setupPie();
        $("#bor").setupPie();
        $("#types").setupPie();
        $("#issues").setupPie();
</#if>
      });
    </script>
  </content>
</head>

<body>
  <#-- Set up the tabs to highlight the info tab, and include a backlink -->
  <#assign tab="stats"/>
  <#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

  <@common.article id="metrics" title="Basic Metrics by">
    <div class="fullwidth">
      <ul class="pies">
        <li><h3>Kingdoms</h3>
          <#if countByKingdom?has_content>
            <p>Number of records within kingdoms of the GBIF Backbone.</p>
            <div id="kingdoms" class="pieMultiLegend">
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
            <p>Number of type specimens.</p>
            <div id="types" class="pieMultiLegend">
              <ul>
              </ul>
            </div>

          <#else>
            <h3>Basis of record</h3>
            <p>Number of records per basis of record.</p>
            <div id="bor" class="pieMultiLegend">
              <ul>
              </ul>
            </div>
          </#if>
        </li>


        <li>
          <h3>Interpretation Issues</h3>
          <#if countByIssues?has_content>
            <p>Number of records having GBIF interpretation issues.</p>
            <div id="issues" class="pieMultiLegend">
              <ul>
                <#list sortedMetricRanks as r>
                  <#if countByRank(r) gt 0>
                    <#assign cnt = metrics.countByRank(r)!0 />
                    <li><a href="<@s.url value='/occurrence/search?dataset_key=${id}&rank=${r}'/>"><@s.text name="enum.rank.${r}"/> <span class="number" data-cnt="${cnt?c}">${cnt}</span></a></li>
                  </#if>
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

  <@common.article id="metrics" title="Overview by kingdom and basis of record">
      <div class="fullwidth">
        <p>
          <@metrics.metricsTable baseAddress="datasetKey=${id}"/>
        </p>
      </div>
  </@common.article>

</body>
</html>
