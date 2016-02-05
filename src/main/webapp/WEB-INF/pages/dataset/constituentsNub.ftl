<#-- @ftlvariable name="" type="org.gbif.portal.action.dataset.ConstituentsAction" -->
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
          <#list constituentCounts?keys as key>
            <li>
                <#if key??>
                    <a title='${constituentTitles[key]!"???"}' href="<@s.url value='/dataset/${key}'/>">${common.limit(constituentTitles[key]!"???", 100)}</a>
                <#else>
                    <a title='algorithm' href="<@s.url value='/dataset/${common.nubKey}'/>">algorithm</a>
                </#if>
                <span class="note">${constituentCounts[key]} primary name references.</span>
            </li>
          </#list>
        </ul>
    </div>
</@common.article>

</body>
</html>
