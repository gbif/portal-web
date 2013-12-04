<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Verbatim Name Usage Data</title>
</head>

<body class="stats">

<#assign tab="info"/>
<#assign tabhl=true />
<#include "/WEB-INF/pages/species/inc/infoband.ftl">



<div class="back">
  <div class="content">
    <a href="<@s.url value='/species/${id?c}'/>" title="Back to regular view">Back to regular view</a>
  </div>
</div>

<@common.notice title="Name Usage verbatim data">
  <p>This listing shows the original information as received by GBIF from the data publisher, without further
    interpretation processing.
  </p>
</@common.notice>

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

</body>
</html>
