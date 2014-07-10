<#import "/WEB-INF/macros/common.ftl" as common>

<#--
	Construct a Type Specimen footer with the sparse supplementory information.
	Type status & scientific name not included here!
	If a citation string is found this is shown only, otherwise the atomic pieces.
-->
<#macro details ts>
  <#-- @ftlvariable name="ts" type="org.gbif.api.model.checklistbank.TypeSpecimen" -->
  <#if ts.citation?has_content>
    <p class="note semi_bottom">${ts.citation}</p>
  </#if>
  <#if ts.locality?has_content>
    <p class="note semi_bottom">${ts.locality}</p>
  </#if>
    <p class="light_note">
      <#assign props = {'Designation type:':'${ts.typeDesignationType!}',
      'Designated by:':'${ts.typeDesignatedBy!}',
      'Label:':'${ts.verbatimLabel!}',
      'Collection date:':'${ts.verbatimEventDate!}',
      'Collector:':'${ts.recordedBy!}',
      'Latitude:':'${ts.verbatimLatitude!}',
      'Longitude:':'${ts.verbatimLongitude!}',
      'Institution code:':'${ts.institutionCode!}',
      'Collection code:':'${ts.collectionCode!}',
      'Catalog number:':'${ts.catalogNumber!}',
      'Occurrence ID:':'${ts.occurrenceId!}'}>
      <#list props?keys as k>
        <#if props[k]?has_content>
        ${k} ${props[k]} <#if k_has_next> | </#if>
        </#if>
      </#list>
    </p>
  <#if ts.source?has_content>
      <p>Source: ${ts.source}</p>
  </#if>
</#macro>
