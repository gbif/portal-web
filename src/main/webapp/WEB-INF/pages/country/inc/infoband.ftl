<#import "/WEB-INF/macros/common.ftl" as common>
<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR A COUNTRY PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 <#assign tab="summary"/>
 <#assign tab="about"/>
 <#assign tab="publishing"/>
 <#assign tab="participation"/>
 <#assign tab="news"/>

 To show yellow tabs instead of default grey ones please assign:
  <#assign tabhl=true />
-->

<content tag="infoband">
  <h1 class="fullwidth">${common.limit(country.title, 70)}</h1>

  <#-- dirty hack again just for troublesome Taiwain -->
  <#if isocode='TW'>
    <h3>A GBIF Associate Participant Economy</h3>
  <#elseif node??>
    <h3>
      <@s.text name="enum.nodestatus.${node.type}.${node.participationStatus}"/>
      <#if node.gbifRegion??> from <@s.text name="enum.region.${node.gbifRegion}"/></#if>
    </h3>
  <#else>
    <h3>&nbsp;</h3>
  </#if>

    <h3>Names of countries, territories and islands are based on the
        <a href="http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm">ISO 3166-1</a> standard.
    </h3>
</content>

<content tag="tabs">
  <#if tabhl!false>
    <#assign hl="highlighted" />
  </#if>
  <ul class="${hl!}">
    <li<#if (tab!"")=="summary"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/country/${isocode}'/>" title="Summary"><span>Summary</span></a>
    </li>
    <li<#if (tab!"")=="about"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/country/${isocode}/about'/>" title="About"><span>Data About</span></a>
    </li>
    <li<#if (tab!"")=="publishing"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/country/${isocode}/publishing'/>" title="Publishing"><span>Data Publishing</span></a>
    </li>
    <#if node?? && node.participationStatus!='FORMER' && node.participationStatus!='OBSERVER'>
      <li<#if (tab!"")=="participation"> class='selected ${hl!}'</#if>>
        <a href="<@s.url value='/country/${isocode}/participation'/>" title="Participation"><span>Participation</span></a>
      </li>
    </#if>
    <li<#if (tab!"")=="news"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/country/${isocode}/news'/>" title="News"><span>News</span></a>
    </li>
    <li<#if (tab!"")=="publications"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/country/${isocode}/publications'/>" title="Publications"><span>Publications</span></a>
    </li>
  </ul>
</content>
