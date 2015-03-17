<#-- @ftlvariable name="" type="org.gbif.portal.action.species.VerbatimAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Verbatim Name Usage Data</title>
</head>

<body class="stats">

<#assign tab="verbatim"/>
<#include "/WEB-INF/pages/species/inc/infoband.ftl">

<@common.notice title="Name Usage verbatim data">
  <p>This listing shows the original information as received by GBIF from the data publisher, without further
    interpretation processing.
  </p>
</@common.notice>

<#if verbatim??>
  <@common.article id="taxon" title="Taxon" class="raw odd">
  <div class="left">
    <#list verbatim.fields?keys as term>
      <div class="row <#if term_index==0>first</#if> <#if term_index % 2 == 0>odd<#else>even</#if> <#if !term_has_next>last</#if>">
        <h4>${term}</h4>
        <div class="value">${verbatim.fields.get(term)!}</div>
      </div>
    </#list>
  </div>
  </@common.article>

  <#list verbatim.extensions?keys as ext>
   <#list verbatim.extensions.get(ext) as rec>
    <#assign title><@s.text name='enum.extension.${ext}'/> - ${rec_index}</#assign>
    <@common.article id="${ext}_${rec_index}" title=title class="raw odd">
      <div class="left">
        <#list rec?keys as term>
          <div class="row <#if term_index==0>first</#if> <#if term_index % 2 == 0>odd<#else>even</#if> <#if !term_has_next>last</#if>">
            <h4>${term}</h4>
            <div class="value">${rec.get(term)!}</div>
          </div>
        </#list>
      </div>
    </@common.article>
   </#list>
  </#list>

<#else>
  <#-- no verbatim record existing -->
  <@common.article id="noData" title="No verbatim data">
      <div class="fullwidth">
          <p>We are sorry but this taxon does not yet have a verbatim version.</p>
          <p>GBIF is reindexing all data continously and the verbatim record will be generated the next time.</p>
      </div>
  </@common.article>
</#if>

</body>
</html>
