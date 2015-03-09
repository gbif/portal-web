<#import "/WEB-INF/macros/common.ftl" as common>
<#assign title>
<#compress>
  <#if node.key == common.taiwanNodeKey>${node.country.title}<#else>${node.title}</#if>
</#compress>
</#assign>

<#assign subtitle>
  <#compress>
  <#--
   dont show a status for the GBIF Temp Node: http://dev.gbif.org/issues/browse/PF-966
   dont show a status for the Participant Node Managers Committee
   -->
    <#if node.key != common.tempNodeKey && node.key != common.participantNMCKey>
      <@s.text name="enum.nodestatus.${node.type}.${node.participationStatus}"/>
      <#if node.gbifRegion??> from <@s.text name="enum.region.${node.gbifRegion}"/></#if>
    </#if>
  </#compress>
</#assign>
