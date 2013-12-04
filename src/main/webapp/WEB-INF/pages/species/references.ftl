<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Vernacular Names for ${usage.canonicalOrScientificName!}</title>
</head>

<body class="species">

<#assign tab="info"/>
<#assign tabhl=true />
<#include "/WEB-INF/pages/species/inc/infoband.ftl">

  <div class="back">
    <div class="content">
      <a href="<@s.url value='/species/${id?c}'/>" title="Back to species overview">Back to species overview</a>
    </div>
  </div>

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2>${page.count!""} References for "${usage.canonicalOrScientificName!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

        <#list page.results as item>
        <div class="result">
          <h2><strong>${item.title!item.citation!}</strong>
            <span class="note">${item.type!}<#if item.link?has_content> <a href="#" target="_blank">link</a></#if></span>
            <@common.usageSource component=item showChecklistSource=usage.nub showChecklistSourceOnly=true/>
          </h2>
          <div class="footer">
            <#if item.citation?has_content>
              ${item.citation}
            <#else>
              ${item.author!} ${item.title!} ${(item.date?date?string)!}
            </#if>
            <br/>
            <#if item.doi?has_content>
              <a href="http://dx.doi.org/${item.doi}" target="_blank">DOI ${item.doi}</a>
            </#if>
        </div>
        </div>
        </#list>

        <div class="footer">
          <@paging.pagination page=page url=currentUrlWithoutPage/>
        </div>

      </div>

    </div>
    <footer></footer>
  </article>

</body>
</html>
