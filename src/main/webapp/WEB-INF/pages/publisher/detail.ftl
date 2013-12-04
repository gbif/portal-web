<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Data Publisher - ${member.title}</title>
</head>
<body class="publisher">


<#assign tab="info"/>
<#include "/WEB-INF/pages/member/inc/infoband.ftl">

<@common.article id="information" title="Data publisher information">
  <#assign extraRight>
    <#if node?? && member.endorsementApproved>
        <h3>Endorsed by</h3>
        <p><a href="<@s.url value='/node/${node.key}'/>">${node.title}</a></p>
    <#else>
        <h3>Not endorsed yet</h3>
    </#if>
  </#assign>
  <#include "/WEB-INF/pages/member/inc/basics.ftl">
</@common.article>

<#if page.results?has_content>

  <#-- Occurrence cube provides no publisher metrics, so we have no way to know if the map has content -->
  <@common.article titleRight='Georeferenced data' class="map">
    <div id="map" class="map">
      <iframe id="mapframe" name="mapframe" src="${cfg.tileServerBaseUrl!}/index.html?type=PUBLISHER&key=${id!}&style=classic&resolution=4" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>
    </div>
    <div class="right">
       <div class="inner">
         <h3>About</h3>
         <p>The map shows georeferenced data for all datasets published</p>  
       </div>
    </div>
  </@common.article>

<@common.article id="datasets" title="Published datasets">
  <div class="fullwidth">
      <ul class="notes">
        <#list datasets as cw>
          <@common.datasetListItem title=cw.obj.title key=cw.obj.key type=cw.obj.type modified=cw.obj.modified count=cw.count geoCount=cw.geoCount></@common.datasetListItem>
        </#list>
        <#if !page.isEndOfRecords()>
          <li class="more">
            <a href="<@s.url value='/publisher/${member.key}/datasets'/>">more</a>
          </li>
        </#if>
      </ul>
  </div>
</@common.article>
</#if>
<#if installationsPage.results?has_content>
  <@common.article id="installations" title="Hosted installations">
      <div class="fullwidth">
          <ul class="notes">
            <#list installationsPage.results as i>
                <li>
                  <a href="<@s.url value='/installation/${i.key}'/>">${i.title!"???"}</a>
                  <span class="note"><@s.text name="enum.installationtype.${i.type!}"/></span>
                </li>
            </#list>
            <#if !installationsPage.isEndOfRecords()>
                <li class="more">
                    <a href="<@s.url value='/publisher/${member.key}/installations'/>">more</a>
                </li>
            </#if>
          </ul>
      </div>
  </@common.article>
</#if>

</body>
</html>
