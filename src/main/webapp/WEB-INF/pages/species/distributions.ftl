<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Distributions for ${usage.canonicalOrScientificName!}</title>
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


  <@common.notice title="Named Area Identifiers">
    <p>
      Geographical distributions are currently not interpreted, but many area identifiers used <br/>
      should follow the <a href="http://rs.gbif.org/areas/">Named Area Standards</a> recommended by GBIF to publishers.
    </p>
  </@common.notice>

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2>${page.count!} Distributions for "${usage.canonicalOrScientificName!}"</h2>
        </div>
      </div>

      <div class="fullwidth">

          <#if page.results?has_content>
            <#list page.results as item>
              <div class="result">
                <h2><strong><#if item.country?? && item.country != 'UNKNOWN'>${item.country.title}: </#if>${item.locality!} ${item.locationId!}</strong>
                  <span class="note">
                    <@s.text name='enum.occurrencestatus.${item.status!"PRESENT"}'/><#if item.establishmentMeans??>, <@s.text name='enum.establishmentmeans.${item.establishmentMeans}'/></#if>
                  </span>
                </h2>
                <div class="footer">
                  <#if item.lifeStage?? || item.temporal?? || item.startDayOfYear?? || item.endDayOfYear??>
                    <p>
                      ${item.lifeStage!} ${item.temporal!}
                      <#if item.startDayOfYear?? || item.endDayOfYear??>Days of the year: ${item.startDayOfYear!}-${item.endDayOfYear!}</#if>
                    </p>
                  </#if>
                  <#if item.threatStatus?? || item.appendixCites??>
                    <p>
                    <#if item.threatStatus??><@s.text name="enum.threatstatus.${item.threatStatus}"/></#if>
                    <#if item.appendixCites??>Cites: ${item.appendixCites}</#if>
                    </p>
                  </#if>
                  <#if usage.nub>
                    <p>Source: <a href='<@s.url value='/species/${item.usageKey?c}'/>'>${(datasets.get(item.datasetKey).title)!"???"}</a></p>
                  </#if>
                </div>
              </div>
            </#list>
          <#else>
            <h3>None</h3>
            <p>&nbsp;</p>
          </#if>

        <div class="footer">
        <@paging.pagination page=page url=currentUrlWithoutPage/>
        </div>
      </div>
    </div>

    </div>
    <footer></footer>
  </article>

</body>
</html>
