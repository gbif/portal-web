<#-- @ftlvariable name="" type="org.gbif.portal.action.occurrence.DetailAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Verbatim Occurrence Detail ${id?c}</title>

</head>
<body class="stats">

<#assign tab="verbatim"/>
<#include "/WEB-INF/pages/occurrence/inc/infoband.ftl">


<@common.notice title="Occurrence verbatim data">
  <p>This listing shows the original information as GBIF extracted it from the source dataset,
    without further interpretation processing.
    <#if fragmentExists>
      Alternatively you can also view the <a href="<@s.url value='/occurrence/${id?c}/fragment'/>">raw XML or JSON</a>
      (for dwc archives) which contains the entire content.
    </#if>
  </p>
</@common.notice>

<#list verbatim?keys as group>
  <@common.article id=group title=group class="raw odd">
  <div class="left">
    <#list verbatim[group]?keys as term>
      <div class="row <#if term_index==0>first</#if> <#if term_index % 2 == 0>odd<#else>even</#if> <#if !term_has_next>last</#if>">
        <h4>${term}</h4>
        <div class="value">${verbatim[group].get(term)!"Value is null"}</div>
      </div>
    </#list>
  </div>
  </@common.article>
</#list>

<#list verbatimExtensions?keys as ext>
  <#list verbatimExtensions.get(ext) as rec>
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



</body>
</html>
