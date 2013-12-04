<#import "/WEB-INF/macros/common.ftl" as common>

<#assign apiUrl = "http://api.gbif.org/v0.9">


<#macro introArticle>
  <@common.article id="overview" title="Introduction" titleRight="Quick links">
  <#nested />
  </@common.article>
</#macro>


<#macro article id title>
  <@common.article id=id title=title>
    <div class="fullwidth">
    <#nested />
    </div>
  </@common.article>
</#macro>


<#macro apiTable method=true auth=true paging=true params=true>
<table class='api table table-bordered table-striped table-params'>
    <thead>
    <tr>
        <th>Resource URL</th>
      <#if method>
        <th>Method</th>
      </#if>
        <th>Response</th>
        <th>Description</th>
      <#if auth>
        <th>Auth</th>
      </#if>
      <#if paging>
        <th>Paging</th>
      </#if>
      <#if params>
        <th width="16%">Parameters</th>
      </#if>
    </tr>
    </thead>

    <tbody>
    <#nested />
    </tbody>
</table>
</#macro>



<#macro trow url httpMethod resp respLink="" paging=false showParams=true params=[] authRequired=false>
<tr>
    <td class="nowrap">${url}</td>
    <td class="nowrap">${httpMethod?upper_case}</td>
    <td class="wordwrap"><#if respLink?has_content><a href="${apiUrl}${respLink}" target="_blank">${resp}</a><#else>${resp}</#if></td>
    <td><#nested/></td>
  <#if authRequired?string!="">
    <td class="nowrap">${authRequired?string}</td>
  </#if>
  <#if paging?string!="">
    <td class="nowrap">${paging?string}</td>
  </#if>
  <#if showParams>
    <td class="wordwrap"><#list params as p><a href='#p_${p}'>${p}</a><#if p_has_next>, </#if></#list></td>
  </#if>
</tr>
</#macro>


<#macro paramArticle params apiName addSearchParams=false>
<#if addSearchParams>
  <#assign params2={
  "hl": "Set hl=true to highlight terms matching the query when in fulltext search fields. The highlight will be an emphasis tag of class 'gbifH1' e.g. <a href='http://api.gbif.org/dataset/search?q=plant&hl=true' target='_blank'>/search?q=plant&hl=true</a>. Fulltext search fields include: title, keyword, country, publishing country, owning organization title, hosting organization title, and description. One additional full text field is searched which includes information from metadata documents, but the text of this field is not returned in the response.",
  "facet_only": "Used in combination with the facet parameter. Set facet_only=true to show only facets and exclude search results.",
  "facet_mincount": "Used in combination with the facet parameter. Set facet_mincount={#} to exclude facets with a count less than {#}, e.g. <a href='http://api.gbif.org/dataset/search?facet=type&facet_only=true&facet_mincount=10000' target='_blank'>/search?facet=type&facet_only=true&facet_mincount=10000</a> only shows the type value 'OCCURRENCE' because 'CHECKLIST' and 'METADATA' have counts less than 10000.",
  "facet_multiselect": "Used in combination with the facet parameter. Set facet_multiselect=true to still return counts for values that are not currently filtered, e.g. <a href='http://api.gbif.org/dataset/search?facet=type&facet_only=true&type=CHECKLIST&facet_multiselect=true' target='_blank'>/search?facet=type&facet_only=true&type=CHECKLIST&facet_multiselect=true</a> still shows type values 'OCCURRENCE' and 'METADATA' even though type is being filtered by type=CHECKLIST"
  }+params />
<#else>
  <#assign params2=params />
</#if>
<@common.article id="parameters" title="Query parameters explained">
  <div class="fullwidth">
      <p>The following parameters are for use exclusively with the ${apiName} API described above.</p>
      <table class='table table-bordered table-striped table-params'>
          <thead>
          <tr>
              <th width="25%" class='total'>Parameter</th>
              <th width="75%">Description</th>
          </tr>
          </thead>

          <tbody>
          <#list params2?keys?sort as k>
            <tr>
                <td><a id="p_${k}"></a>${k}</td>
                <td>${params2[k]}</td>
            </tr>
          </#list>
          </tbody>
      </table>
  </div>
</@common.article>
</#macro>
