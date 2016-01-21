<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>${dataset.title!"???"} - Constituents</title>
</head>
<body class="species">

<#assign tab="constituents"/>
<#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

<@common.article id="datasets" title="GBIF Backbone Source Datasets">
    <div class="fullwidth">
        <p>The source datasets that contributed to the GBIF Backbone and the number of names that were used as primary references.</p>
        <ul class="notes">
          <#list constituentsNub as c>
            <li>
                <a title="${c.title}" href="<@s.url value='/dataset/${c.key}'/>">${common.limit(c.title, 100)}</a>
                <span class="note">${c.count} primary name references.</span>
            </li>
          </#list>
        </ul>
    </div>
</@common.article>

</body>
</html>
