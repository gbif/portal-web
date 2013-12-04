<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/records.ftl" as record>
<html>
<head>
  <title>${dataset.title!"???"} - Constituents</title>
</head>
<body class="species">

<#assign tab="constituents"/>
<#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2>${page.count!} Constituent datasets for "${dataset.title!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list page.results as item>
        <@record.dataset dataset=item/>
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
