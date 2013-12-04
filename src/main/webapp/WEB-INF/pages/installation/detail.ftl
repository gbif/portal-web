<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
    <title>Installation - ${member.title}</title>
</head>
<body class="publisher">


<#assign tab="info"/>
<#include "/WEB-INF/pages/member/inc/infoband.ftl">

<@common.article id="information" title="Installation information">
  <#assign extraRight>
      <h3>Type</h3>
      <p><#if member.type?starts_with("IPT")><a href="/ipt"><@s.text name="enum.installationtype.${member.type}"/></a><#else><@s.text name="enum.installationtype.${member.type}"/></#if></p>
      <h3>Hosted by</h3>
      <p><a href="<@s.url value='/publisher/${organization.key}'/>">${organization.title}</a></p>

    <#if member.endpoints?size &gt; 0>
        <h3>Access points</h3>

        <!-- find IPT Feed access point -->
      <#assign feedURL = ""/>
      <#assign rssIndex = 0/>
      <#list member.endpoints as end>
        <#if end.type?string == 'FEED'>
          <#assign feedURL = end.url?string/>
          <#assign rssIndex = feedURL?index_of("rss.do")/>
        </#if>
      </#list>

        <!-- list all access points -->
        <ul>
            <!-- Only show homepage for IPTs with a resolvable IPT URL -->
            <!-- Parse out homepage URL from Feed endpoint URL, everything up until rss.do -->
          <#if member.type?string == common.iptInstallationType && feedURL != "" && rssIndex &gt; 0>
            <#assign iptBaseUrl = feedURL?substring(0, rssIndex)/>
              <li><a href="<@s.url value=iptBaseUrl/>" target="_blank" title="IPT Homepage">Homepage</a></li>
          </#if>

          <#list member.endpoints as end>
              <li><a href="${end.url}" target="_blank" title="${end.type} access point"><@s.text name="enum.endpointtype.${end.type}"/></a></li>
          </#list>
        </ul>
    </#if>


  </#assign>
  <#include "/WEB-INF/pages/member/inc/basics.ftl">
</@common.article>

<#if page.results?has_content>

  <@common.article id="datasets" title="Served datasets">
      <div class="fullwidth">
          <ul class="notes">
            <#list datasets as cw>
              <@common.datasetListItem title=cw.obj.title key=cw.obj.key type=cw.obj.type modified=cw.obj.modified owningOrganizationKey=cw.obj.owningOrganizationKey owningOrganizationTitle=action.getOrganization(cw.obj.owningOrganizationKey).title count=cw.count geoCount=cw.geoCount></@common.datasetListItem>
            </#list>
            <#if !page.isEndOfRecords()>
                <li class="more">
                    <a href="<@s.url value='/installation/${member.key}/datasets'/>">more</a>
                </li>
            </#if>
          </ul>
      </div>
  </@common.article>
</#if>


</body>
</html>
