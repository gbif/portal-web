<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Occurrence detail - GBIF</title>

</head>
<body class="stats">

<#assign tab="info-verbatim"/>
<#include "/WEB-INF/pages/occurrence/inc/infoband.ftl">



<div class="back">
  <div class="content">
    <a href="<@s.url value='/occurrence/${id?c}'/>" title="Back to regular view">Back to regular view</a>
  </div>
</div>

<@common.notice title="Occurrence verbatim data">
  <p>This listing shows the original information as received by GBIF from the data publisher, without further
    interpretation processing. Please note that the verbatim data is currently limited to a subset of only 40 terms.
    <#if fragmentExists>Alternatively you can also view the
    <a href="<@s.url value='/occurrence/${id?c}/fragment'/>">raw XML or JSON</a> (for dwc archives) which contains the entire content.</#if>
  </p>
</@common.notice>

<#list verbatim?keys as group>
  <@common.article id="record_level" title=group class="raw odd">
  <div class="left">
    <#list verbatim[group]?keys as term>
      <div class="row <#if term_index==0>first</#if> <#if term_index % 2 == 0>odd<#else>even</#if> <#if !term_has_next>last</#if>">
        <h4>${term}</h4>
        <div class="value">${verbatim[group].get(term)}</div>
      </div>
    </#list>
  </div>
  </@common.article>
</#list>

</body>
</html>
