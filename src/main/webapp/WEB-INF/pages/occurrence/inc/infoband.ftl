<#-- @ftlvariable name="" type="org.gbif.portal.action.occurrence.OccurrenceBaseAction" -->
<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR AN OCCURRENCE PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 For the usual page
 <#assign tab="info"/>
 <#assign tab="verbatim"/>
 <#assign tab="activity"/>
 <#assign tab="stats"/>
-->

<content tag="infoband">
  <#-- display occurrence id in source data. If not provided show GBIF generated occurrence id instead -->
  <#assign occurrenceID = action.termValue('occurrenceID')! />
  <#if occurrenceID?has_content>
    <h1>${occurrenceID}</h1>
  <#else>
    <h1>GBIF ${id?c}</h1>
  </#if>

  <h3><@s.text name="enum.basisofrecord.${occ.basisOfRecord!'UNKNOWN'}"/> of
    <#if occ.taxonKey??>
      <a href="<@s.url value='/species/${occ.taxonKey?c}'/>">${occ.scientificName}</a>
    <#else>
      a <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>">name which can't be interpreted</a>
    </#if>
    <#if occ.eventDate??>
      recorded on ${occ.eventDate!?date?string.medium}
    </#if>
  </h3>
  <h3>
    from <a href="<@s.url value='/dataset/${dataset.key!}'/>">${dataset.title!"???"}</a> dataset
  </h3>
</content>

<content tag="tabs">
  <#assign hl="" />
  <ul class="${hl}">
    <li<#if (tab!)=="info"> class='selected ${hl}'</#if>>
      <a href="<@s.url value='/occurrence/${id?c}'/>" title="Information"><span>Information</span></a>
    </li>
    <li<#if (tab!)=="verbatim"> class='selected ${hl!}'</#if>>
        <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>" title="Verbatim"><span>Verbatim</span></a>
    </li>
    <#-- Commented out http://dev.gbif.org/issues/browse/PF-55
    <li<#if tab=="activity"> class='selected ${hl}'</#if>>
      <a href="#" title="Activity"><span>Activity</span></a>
    </li>
    <li<#if tab=="stats"> class='selected ${hl}'</#if>>
      <a href="#" title="Stats"><span>Stats</span></a>
    </li>
    -->
  </ul>
</content>

