<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Network detail</title>
</head>
<body class="species">

<#assign tab="info"/>
<#include "/WEB-INF/pages/member/inc/infoband.ftl">

<@common.article id="information" title="Network information">
  <#include "/WEB-INF/pages/member/inc/basics.ftl">
</@common.article>

<#if page.results?has_content>
<@common.article id="datasets" title="Participating datasets: ${member.numConstituents}">
  <div class="fullwidth">
      <ul class="notes">
        <#list datasets as cw>
          <@common.datasetListItem title=cw.obj.title key=cw.obj.key type=cw.obj.type modified=cw.obj.modified owningOrganizationKey=cw.obj.owningOrganizationKey owningOrganizationTitle=action.getOrganization(cw.obj.owningOrganizationKey).title count=cw.count geoCount=cw.geoCount></@common.datasetListItem>
        </#list>
        <#if !page.isEndOfRecords()>
            <li class="more">
                <a href="<@s.url value='/network/${member.key}/datasets'/>">more</a>
            </li>
        </#if>
      </ul>
  </div>
</@common.article>
</#if>

</body>
</html>
