<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR AN OCCURRENCE PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 For the usual page
 <#assign tab="info"/>
 <#assign tab="info-verbatim"/>
 <#assign tab="activity"/>
 <#assign tab="stats"/>
-->

<content tag="infoband">
  <#-- display occurrence id in source data. If not provided show GBIF generated occurrence id instead -->
  <#assign occurrenceID = action.retrieveTerm('occurrenceID')! />
  <#if occurrenceID?has_content>
    <h1>${occurrenceID}</h1>
  <#else>
    <h1>GBIF ID: ${id?c}</h1>
  </#if>

  <h3><@s.text name="enum.basisofrecord.${occ.basisOfRecord!'UNKNOWN'}"/> of
    <#if occ.taxonKey??>
      <a href="<@s.url value='/species/${occ.taxonKey?c}'/>">${occ.scientificName}</a>
    <#else>
      a name which cant be interpreted. <br/>
      Please see the <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>">verbatim version</a> for source details
    </#if>
    <#if occ.eventDate??>
      on ${occ.eventDate?date?string.medium}
    </#if>
    from <a href="<@s.url value='/dataset/${dataset.key!}'/>">${dataset.title!"???"}</a> dataset
  </h3>
</content>

<content tag="tabs">
  <#if !tab??><#assign tab="" /></#if>
  <#assign hl="" />
  <#if tab=="info-verbatim">
    <#assign hl="highlighted" />
  </#if>
  <ul class="${hl}">
    <li<#if tab=="info" || tab=="info-verbatim"> class='selected ${hl}'</#if>>
      <a href="<@s.url value='/occurrence/${id?c}'/>" title="Information"><span>Information</span></a>
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
