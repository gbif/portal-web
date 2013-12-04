<#import "/WEB-INF/macros/common.ftl" as common>
<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR A MEMBER PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 <#assign tab="info"/>
 <#assign tab="activity"/>
 <#assign tab="datasets"/>
 <#assign tab="stats"/>
-->
<content tag="infoband">

 <h1 class="fullwidth">
  <#if node.key == common.taiwanNodeKey>
    ${node.country.title}
  <#else>
    ${common.limit(node.title, 70)}
  </#if>
 </h1>

  <h3>
      <#--
      dont show a status for the GBIF Temp Node:
      http://dev.gbif.org/issues/browse/PF-966
      -->
    <#if node.key != common.tempNodeKey>
      <@s.text name="enum.nodestatus.${node.type}.${node.participationStatus}"/>
      <#if node.gbifRegion??> from <@s.text name="enum.region.${node.gbifRegion}"/></#if>
    </#if>
  </h3>

  <#if keywords?has_content>
    <ul class="tags">
      <#list keywords as k>
          <li>
              <a href="#" title="${k}">${k}</a>
          </li>
      </#list>
    </ul>
  </#if>
</content>

<content tag="tabs">
  <#if tabhl!false>
    <#assign hl="highlighted" />
  </#if>
  <ul class="${hl!}">
    <li<#if (tab!"")=="info"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/node/${id}'/>" title="Information"><span>Information</span></a>
    </li>
  </ul>
</content>
