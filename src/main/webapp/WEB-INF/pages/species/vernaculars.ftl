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
          <h2>${page.count!} Vernacular names for "${usage.canonicalOrScientificName!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list page.results as item>
        <div class="result">
          <h2>
            <a href='<@s.url value='/species/${item.usageKey?c}'/>'><strong>${item.vernacularName}</strong></a>
            <span class="note">${item.language!}</span>
          </h2>
          <#if item.lifeStage?? || item.sex?? || (item.country!'UNKNOWN') != 'UNKNOWN' || item.area??>
            <div class="footer">${item.lifeStage!} ${item.sex!} <#if (item.country!'UNKNOWN') != 'UNKNOWN' >${item.country} </#if>${item.area!}</div>
          </#if>

          <div class="footer">

            <#if item.remarks?has_content>
              <p>Remarks: ${item.remarks}</p>
            </#if>

            <#if nub>
              <p>According to ${(datasets.get(item.datasetKey).title)!"???"}</p>
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
