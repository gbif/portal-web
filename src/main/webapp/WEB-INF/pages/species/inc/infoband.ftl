<#import "/WEB-INF/macros/common.ftl" as common>
<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR A SPECIES PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 <#assign tab="info"/>
 <#assign tab="activity"/>
 <#assign tab="stats"/>

 To show yellow tabs instead of default grey ones please assign:
  <#assign tabhl=true />
-->

<#assign showBox = usage.nub && !(tabhl!false) />
<#assign titleLength = 36 />
<#if !showBox>
  <#assign titleLength = 48 />
</#if>

<content tag="infoband">
  <h1<#if !showBox> class="fullwidth"</#if>>${common.limit(usage.scientificName, titleLength)}</h1>
  <h3><#if usage.isExtinct()!false>Extinct ${(usage.rank!"Unranked")?lower_case}<#else>${(usage.rank!"Unranked")?capitalize}</#if>
    <#if usage.synonym> synonym</#if>
    in <a href="<@s.url value='/dataset/${usage.datasetKey}'/>">${(dataset.title)!"???"}</a>
  </h3>
  <h3>
  <#assign classification=usage.higherClassificationMap />
  <#list classification?keys as key>
    <a href="<@s.url value='/species/${key?c}'/>">${classification.get(key)}</a><#if key_has_next> &#x203A; </#if>
  </#list>
  </h3>

<#if showBox>
  <div class="box">
    <div class="content">
      <ul>
        <li><h4>${numOccurrences}</h4>Occurrences</li>
        <#if usage.rank.isSpeciesOrBelow()>
          <li class="last"><h4>${usage.numDescendants}</h4>Infraspecies</li>
        <#else>
          <li class="last"><h4>${usageMetrics.numSpecies}</h4>Species</li>
        </#if>
      </ul>
      <a href="<@s.url value='/occurrence/search?taxon_key=${usage.key?c}'/>" title="View Occurrences" class="candy_blue_button"><span>View occurrences</span></a>
    </div>
  </div>
</#if>

</content>

<content tag="tabs">
  <#if tabhl!false>
    <#assign hl="highlighted" />
  </#if>
  <ul class="${hl!}">
    <li<#if (tab!"")=="info"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/species/${id?c}'/>" title="Information"><span>Information</span></a>
    </li>
    <#--
    NOT IMPLEMENTED YET
    <li<#if (tab!"")=="activity"> class='selected ${hl!}'</#if>>
      <a href="#" title="Activity"><span>Activity</span></a>
    </li>
    <li<#if (tab!"")=="stats"> class='selected ${hl!}'</#if>>
      <a href="#" title="Stats"><span>Stats</span></a>
    </li>
    -->
  </ul>
</content>
