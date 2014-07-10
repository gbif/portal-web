<#-- @ftlvariable name="" type="org.gbif.portal.action.species.ReferenceAction" -->
<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Bibliography for ${usage.canonicalOrScientificName!}</title>
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
          <h2>${page.count!""} Bibliography for "${usage.canonicalOrScientificName!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

        <#list page.results as item>
        <div class="result">
          <h2><strong>${item.title!item.author!(item.date?date?string)!}</strong>
            <span class="note">${item.type!}<#if item.link?has_content> <a href="${item.link}" target="_blank">link</a></#if></span>
          </h2>

        <p>
          <#if item.citation?has_content>
              ${item.citation!}
          </#if>
        </p>
          <div class="footer">
            <#if item.doi?has_content>
              <p>DOI: <a href="http://dx.doi.org/${item.doi}" target="_blank">${item.doi}</a></p>
            </#if>
            <#if item.source?has_content>
                <p>Source: ${item.source}</p>
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
