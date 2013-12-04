<#import "/WEB-INF/macros/common.ftl" as common>

<#if node??>
<@common.article id="participation" title="GBIF participant information" titleRight="Node">
    <div class="left">
        <#--
        dont show a status for the GBIF Temp Node:
        http://dev.gbif.org/issues/browse/PF-966
        -->
      <#if node.key != '02c40d2a-1cba-4633-90b7-e36e5e97aba8'>
          <h3>Member Status</h3>
          <p><@s.text name="enum.memberstatus.${node.type}.${node.participationStatus}"/></p>
      </#if>


      <#if node.participantSince??>
        <h3>GBIF Participant Since</h3>
        <p>${node.participantSince?c}</p>
      </#if>

      <#if node.gbifRegion?has_content>
        <h3>GBIF Region</h3>
        <p><@s.text name="enum.region.${node.gbifRegion}"/></p>
      </#if>

      <#if node.type == 'COUNTRY'>
        <#assign contactBaseUrl><@s.url value='/country/${isocode}/participation'/></#assign>
      <#else>
        <#assign contactBaseUrl><@s.url value='/node/${node.key}'/></#assign>
      </#if>

      <#if headOfDelegation??>
        <h3>Head of Delegation</h3>
        <p>
            <a href="${contactBaseUrl}#contact${headOfDelegation.key?c}">${headOfDelegation.firstName!} ${headOfDelegation.lastName!}</a>
        </p>
      </#if>

      <#if nodeManagers?has_content>
        <h3>Node Manager<#if nodeManagers?size gt 1>s</#if></h3>
        <p>
          <#list nodeManagers as nm>
            <a href="${contactBaseUrl}#contact${nm.key?c}">${nm.firstName!} ${nm.lastName!}</a><#if nm_has_next>, </#if>
          </#list>
        </p>
      </#if>

      <#if (showDescription!false) && node.description?has_content>
        <h3>Description</h3>
        <p>${node.description}</p>
      </#if>

    </div>

    <div class="right">
      <#if node?? && node.logoURL?has_content>
        <div class="logo_holder">
          <img src="${node.logoURL}"/>
        </div>
      </#if>

      <#if node??>
        <h3>Node name</h3>
        <p>${node.title}</p>

        <h3>Address</h3>
        <#if node.institution?has_content>
          <p>${node.institution}</p>
        </#if>
        <@common.address address=node />

        <#if node.homepage?has_content>
          <h3>Website</h3>
          <p><a href="${node.homepage}" target="_blank">${node.homepage}</a></p>
        </#if>
      </#if>
    </div>
</@common.article>
</#if>
