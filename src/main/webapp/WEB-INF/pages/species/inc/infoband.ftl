<#-- @ftlvariable name="" type="org.gbif.portal.action.species.UsageBaseAction" -->
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
<#assign classificationLineLength = 85 />
<#if !showBox>
  <#assign titleLength = 48 />
</#if>

text-decoration: line-through;

<content tag="infoband">
  <h1 class="<#if !showBox>fullwidth</#if><#if usage.deleted??> deleted</#if>">${common.limit(usage.scientificName, titleLength)}</h1>
  <h3><#if usage.deleted??>Deleted </#if><#if usage.isExtinct()!false>Extinct ${(usage.rank!"Unranked")?lower_case}<#else>${(usage.rank!"Unranked")?capitalize}</#if>
    <#if usage.synonym> synonym</#if>
    in <a href="<@s.url value='/dataset/${usage.datasetKey}'/>">${(dataset.title)!"???"}</a>
  </h3>
  <h3>
  <#assign classification=usage.higherClassificationMap />
  <#assign classificationLength = 0 />
  <#list classification?keys as key>
    <#assign classificationText = classification.get(key) />
    <#if classificationText?has_content>
      <#assign classificationLength = classificationLength + classificationText?length />
    </#if>

    <a href="<@s.url value='/species/${key?c}'/>">${classificationText!}</a><#if key_has_next> &#x203A;
    <#assign classificationLength = classificationLength + 3/></#if>
    <#if classificationLength gte classificationLineLength>
      <#assign classificationLength = 0/>
      <br>
    </#if>
  </#list>
  </h3>

<#if showBox>
  <div class="<#if numOccurrences == 0>smallbox<#else>box</#if>">
    <div class="content">
      <#-- This margin is used when the species doesn't have occurrence and because that the background image has a fixed size-->
      <ul>
        <li><h4>${numOccurrences}</h4>Occurrences</li>
        <#if usage.rank.isSpeciesOrBelow()>
          <li class="last"><h4>${usage.numDescendants}</h4>Infraspecies</li>
        <#else>
          <li class="last"><h4>${usageMetrics.numSpecies}</h4>Species</li>
        </#if>
      </ul>
      <#-- Hide box if there not occurrences for this species-->
      <#if numOccurrences gt 0>
        <a href="<@s.url value='/occurrence/search?taxon_key=${usage.key?c}'/>" title="View Occurrences" class="candy_blue_button"><span>View occurrences</span></a>
      </#if>
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
  <#if !nub>
    <#if usage.origin! == "SOURCE">
    <li<#if (tab!"")=="verbatim"> class='selected ${hl!}'</#if>>
        <a href="<@s.url value='/species/${id?c}/verbatim'/>" title="Verbatim"><span>Verbatim</span></a>
    </li>
    </#if>
    <#if usage.nubKey?exists>
    <li>
        <a href="<@s.url value='/species/${usage.nubKey?c}'/>" title="GBIF Backbone"><span>GBIF Backbone</span></a>
    </li>
    </#if>
  </#if>
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
