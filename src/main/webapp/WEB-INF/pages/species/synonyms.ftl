<#import "/WEB-INF/macros/pagination.ftl" as paging>
<html>
<head>
  <title>Synonyms of ${usage.canonicalOrScientificName!}</title>
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
          <h2>${page.count!} Synonyms for "${usage.canonicalOrScientificName!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list page.results as u>
        <div class="result">
          <h3>${u.taxonomicStatus!} <@common.renderNomStatusList u.nomenclaturalStatus /></h3>
          <h2>
            <a href="<@s.url value='/species/${u.key?c}'/>"><strong>${u.scientificName}</strong></a>
            <span class="note"><@s.text name='enum.rank.${u.rank!"UNKNOWN"}'/></span>
          </h2>
          <div class="footer">
            <#if usage.nub>
              <p>According to ${u.accordingTo!u.origin!}</p>
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
