<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>
<html>
<head>
  <title>Dataset constituents of ${member.title!}</title>
</head>

<body class="species">

<#assign tab="info"/>
<#assign tabhl=true />
<#include "/WEB-INF/pages/member/inc/infoband.ftl">

  <div class="back">
    <div class="content">
      <a href="<@s.url value='/network/${id}'/>" title="Back to network">Back to network</a>
    </div>
  </div>

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2>${page.count!} constituent datasets</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list page.results as item>
        <@records.dataset dataset=item showPublisher=true/>
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
