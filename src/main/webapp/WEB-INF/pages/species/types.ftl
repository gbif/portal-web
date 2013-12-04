<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/typespecimen.ftl" as types>
<html>
<head>
  <title>Type Specimens for ${usage.canonicalOrScientificName!}</title>
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
          <h2>${page.count!} Types for "${usage.canonicalOrScientificName!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list page.results as item>
        <div class="result">
          <h2>
            <strong>
              <@types.status item />
            </strong>
            <span class="note"></span>
          </h2>

          <div class="footer">
            <@types.details item />
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
