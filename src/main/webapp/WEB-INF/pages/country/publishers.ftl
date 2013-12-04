<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>
<html>
<head>
  <title>Endorsed data publishers by node ${member.title!}</title>
</head>

<body class="species">

<#assign tabhl=true />
<#if country??>
  <#assign tab="participation"/>
  <#include "/WEB-INF/pages/country/inc/infoband.ftl">
<#else>
  <#assign tab="info"/>
  <#include "/WEB-INF/pages/member/inc/infoband.ftl">
</#if>

  <div class="back">
    <div class="content">
    <#if country??>
      <a href="<@s.url value='/country/${isocode}/participation'/>" title="Back to participation page">Back to participation page</a>
    <#else>
      <a href="<@s.url value='/node/${member.key}'/>" title="Back to node page">Back to node page</a>
    </#if>
    </div>
  </div>

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2>${publisherPage.count!} Endorsed data publishers for "${member.title!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list publisherPage.results as item>
        <@records.publisherWithDescription publisher=item/>
      </#list>
        <div class="footer">
        <@paging.pagination page=publisherPage url=currentUrlWithoutPage/>
        </div>
      </div>

    </div>
    <footer></footer>
  </article>

</body>
</html>
