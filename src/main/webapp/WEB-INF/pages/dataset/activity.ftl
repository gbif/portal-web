<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/records.ftl" as records>
<html>
<head>
  <title>${dataset.title} - Activity</title>
</head>
<body>
  <#-- Set up the tabs to highlight the info tab, and include a backlink -->
  <#assign tab="activity"/>
  <#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

  <#assign downloadTitle="${page.count} download event${(page.count > 1)?string('s','')}"/>
  <@common.article title=downloadTitle class="results">
      <div class="fullwidth">
        <#if !page.results?has_content>
          <p>No data from this dataset has been download so far.</p>
        </#if>

        <#list page.results as du>
          <#assign queryParams=action.getQueryParamsWithoutDataset(du.download.request.predicate)!""/>
          <#if queryParams?has_content>
            <#assign queryParams=queryParams + "&datasetKey=" + dataset.key />
          <#else>
            <#assign queryParams="datasetKey=" + dataset.key />
          </#if>

          <div class="result">
              <div class="footer">
                  <dl>
                      <dt>Download</dt>
                      <dd><@common.doilink doi=du.download.doi url="/occurrence/download/${du.download.key}" /> ${niceDate(du.download.created)}</dd>

                      <dt>Records</dt>
                      <dd><a href="<@s.url value='/occurrence/search?${queryParams}'/>">${du.numberRecords} records</a> from this dataset included at time of download</dd>

                      <dt>Query</dt>
                      <dd><@records.dFilter du.download /></dd>
                  </dl>
                  <p class="small no_bottom"><a href='/occurrence/search?${action.getQueryParams(du.download.request.predicate)!""}'>Reproduce query</a> on latest data</p>
              </div>
          </div>
        </#list>

          <div class="footer">
            <@paging.pagination page=page url=currentUrlWithoutPage/>
          </div>
      </div>
  </@common.article>

</body>
</html>
