<#-- @ftlvariable name="" type="org.gbif.portal.action.dataset.StatsAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
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
        $("#kingdoms").setupPie(${numOccurrences?c});
        $("#bor").setupPie(${numOccurrences?c});
        $("#types").setupPie(${numOccurrences?c});
        $("#issues").setupPie(${numOccurrences?c});
</#if>
      });
    </script>
  </content>
</head>

<body>
  <#-- Set up the tabs to highlight the info tab, and include a backlink -->
  <#assign tab="stats"/>
  <#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

  <@common.article id="metrics" title="Single dimensions">
    <div class="fullwidth">
      <ul class="pies">
        <li><h3>Kingdoms</h3>
          <#if countByKingdom?has_content>
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

  <@common.article id="metrics" title="Basis of record by Kingdom">
      <div class="fullwidth">
        <p>
          <@metrics.metricsTable baseAddress="datasetKey=${id}"/>
        </p>
      </div>
  </@common.article>

</body>
</html>
