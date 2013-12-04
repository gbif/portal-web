<#import "/WEB-INF/macros/occ_metrics.ftl" as metrics>
<html>
<head>
  <title>${dataset.title} - Metrics</title>
  
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
  <script type="text/javascript" src="<@s.url value='/js/occ_metrics.js'/>"></script>
</head>
<body>
  <#-- Set up the tabs to highlight the info tab, and include a backlink -->
  <#assign tab="stats"/>
  <#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

  <@common.article id="metrics" title="Dataset metrics">
      <div class="fullwidth">
        <p>
          <@metrics.metricsTable baseAddress="datasetKey=${id}"/>
        </p>
      </div>
</@common.article>

</body>
</html>
