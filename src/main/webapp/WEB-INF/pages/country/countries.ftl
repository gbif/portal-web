<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<html xmlns="http://www.w3.org/1999/html">
<head>
  <#if about>
    <title>Countries publishing data about ${country.title}</title>
  <#else>
    <title>Countries of origin published by ${country.title}</title>
  </#if>
</head>

<body>

<#if about>
  <#assign tab="about"/>
  <#assign link="publishing"/>
<#else>
  <#assign tab="publishing"/>
  <#assign link="about"/>
</#if>
<#assign tabhl=true />
<#include "/WEB-INF/pages/country/inc/infoband.ftl">

  <div class="back">
    <div class="content">
      <a href="<@s.url value='/country/${isocode}/${tab}'/>" title="Back to summary">Back to Data ${tab?cap_first}</a>
    </div>
  </div>

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <#if about>
            <h2>${countryPage.count!0} countries publishing data about ${country.title}</h2>
          <#else>
            <h2>${countryPage.count!0} countries covered by data published in ${country.title}</h2>
          </#if>
        </div>
      </div>

      <div class="fullwidth">
      <#list countries as cw>
        <div class="result">
          <h2>
              <strong><a title="${cw.obj.getTitle()}" href="<@s.url value='/country/${cw.obj.getIso2LetterCode()}/${link}'/>">${cw.obj.getTitle()}</a></strong>
          </h2>

          <div class="footer">
            ${cw.count} occurrence records<#if cw.geoCount gt 0>, ${100.0 * cw.geoCount / cw.count} % georeferenced</#if>.
          </div>

        </div>
      </#list>

      <div class="footer">
        <@paging.pagination page=countryPage url=currentUrlWithoutPage/>
      </div>

      </div>

    </div>
    <footer></footer>
  </article>

</body>
</html>
