<#import "/WEB-INF/macros/common.ftl" as common>
<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR A DATASET PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 <#assign tab="info"/>
 <#assign tab="constituents"/>
 <#assign tab="activity"/>
 <#assign tab="discussion"/>

 To show yellow tabs instead of default grey ones please assign:
  <#assign tabhl=true />

-->

<#--
  When writing tags under the title we truncate if they are too long.
  If they are truncated, the page flag is set to render the full keywords under the details.
  If there is a box for view occurrences / species, then the UL gets a new class attribute so the width can be controlled.
-->
<#if dataset.type! == "OCCURRENCE" || (dataset.type! == "CHECKLIST" && !parentDataset?has_content)>
  <#assign box=true />
  <#assign maxKeywordChars=140 />
  <#assign titleLength = 36 />
  <#assign subtitleLength = 70 />
<#else>
  <#assign box=false />
  <#assign maxKeywordChars=250 />
  <#assign titleLength = 52 />
  <#assign subtitleLength = 86 />
</#if>


<content tag="infoband">

  <h1<#if !box> class="fullwidth"</#if>>${common.limit(dataset.title, titleLength)}</h1>

  <h3>
    <@s.text name="enum.datasettype.${dataset.type!'UNKNOWN'}"/>
    <#if parentDataset?has_content>
      constituent of <a href="<@s.url value='/dataset/${parentDataset.key}'/>" title="${parentDataset.title!"Unknown"}">${common.limit(parentDataset.title!"Unknown", subtitleLength)}</a>
    <#elseif publisher??>
      published by <a href="<@s.url value='/publisher/${publisher.key}'/>">${common.limit(publisher.title!"Unknown", subtitleLength)}</a>
    </#if>
  </h3>


<#assign keywordTextLength=0 />
  <#-- use this var to indicate the details page if keywords were truncated! -->
<#assign keywordsTruncatedInTitle=false />
<#if keywords?has_content>
  <ul class="tags<#if box==true> narrow</#if>">
    <#list keywords as k>
      <#if keywordTextLength + k?length &gt; maxKeywordChars>
        <li><a href="#keywords">more…</a></li>
        <#assign keywordsTruncatedInTitle=true />
        <#break>
      </#if>
      <li><a href="<@s.url value='/dataset/search?keyword=${k}'/>">${k}</a></li>
      <#assign keywordTextLength=keywordTextLength + k?length />
    </#list>
  </ul>
</#if>

<#if box==true>
    <div class="box">
      <div class="content">
        <#if dataset.type! == "OCCURRENCE">
            <ul>
              <li class="single last"><h4>${numOccurrences!0}</h4>Occurrences</li>
            </ul>
            <a href="<@s.url value='/occurrence/search?datasetKey=${id!}'/>" title="View occurrences" class="candy_blue_button"><span>View occurrences</span></a>
        <#elseif dataset.type! == "CHECKLIST">
            <ul>
                <li><h4>${(metrics.getCountByRank(speciesRank))!"?"}</h4>Species</li>
                <li class="last"><h4>${(metrics.usagesCount)!"?"}</h4>Taxa</li>
            </ul>
            <a href="<@s.url value='/species/search?dataset_key=${id!}'/>" title="View species" class="candy_blue_button"><span>View species</span></a>
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
    <li<#if (tab!)=="info"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/dataset/${id!}'/>" title="Information"><span>Information</span></a>
    </li>
    <#if dataset.numConstituents gt 0>
      <li<#if (tab!)=="constituents"> class='selected ${hl!}'</#if>>
        <a href="<@s.url value='/dataset/${id!}/constituents'/>" title="Constituents"><span>Constituents</span></a>
      </li>
    </#if>
    <#if dataset.type! != "METADATA" && !dataset.parentDatasetKey??>
      <li<#if (tab!)=="stats"> class='selected ${hl!}'</#if>>
        <a href="<@s.url value='/dataset/${id!}/stats'/>" title="Stats"><span>Stats</span></a>
      </li>
    </#if>
<#if dataset.type! == "OCCURRENCE">
    <li<#if (tab!)=="activity"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/dataset/${id!}/activity'/>" title="Activity"><span>Activity</span></a>
    </li>
</#if>
    <#-- Commented out http://dev.gbif.org/issues/browse/PF-56
    <li<#if (tab!)=="discussion"> class='selected ${hl!}'</#if>>
      <a href="#" title="Discussion"><span>Discussion</span></a>
    </li>
    -->
  </ul>
</content>
