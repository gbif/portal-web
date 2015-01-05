<#import "/WEB-INF/macros/records.ftl" as records>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/pagination.ftl" as paging>
<html>
<head>
  <title>Occurrence Download - GBIF</title>
</head>
<body class="search">

<content tag="infoband">
  <div class="content">
    <h1>Occurrence download</h1>
    <h3><@common.doilink doi=download.doi /> ${niceDate(download.created)}</h3>
  </div>
  <#if action.dwcaExists()>
    <div class="box">
      <div class="content">
        <ul>
          <li class="single last"><h4>${download.totalRecords!0}</h4>Occurrences</li>
        </ul>
        <a href="${download.downloadLink}" class="candy_blue_button download_button"><span>Download</span></a>
      </div>
    </div>
  </#if>
</content>


<#if action.isRunning()>
  <@common.notice title="Download running">
      <p>The download has been started and is currently being processed.</p>
      <p>Please expect 10 to 15 minutes for the download to complete.</p>
      <#if currentUser?? && currentUser.userName=download.request.creator>
        <p>A notification email with a link to download the results will be sent to the following addresses once ready:
          <ul>
            <#list download.request.notificationAddresses as email>
                <li>${email}</li>
            </#list>
          </ul>
        </p>
      </#if>
  </@common.notice>

<#elseif download.isAvailable()>
  <@common.notice title="Please note">
      <p>The download result will be retained for as long as possible, but might be removed in the future.</p>
      <p>The <@common.doilink doi=download.doi url="/occurrence/download/${download.key}"/> will always resolve to this page, even if the download is removed.</p>
  </@common.notice>

<#else>
  <@common.notice title="${download.status}">
      <p>The download request was unsuccessful. Please try it again or contact the <@common.helpdesk/>.</p>
  </@common.notice>
</#if>

<@common.article id="details" title="Download details" class="results">
  <div class="fullwidth">
    <dl>
      <dt>Identifier</dt>
      <dd><@common.doi download.doi /></dd>

      <dt>Cite as</dt>
      <dd><@common.citeDownload download/></dd>

      <dt>Query</dt>
      <dd><@records.dFilter download /></dd>

      <#if download.isAvailable()>
        <dt>Size</dt>
        <dd>${action.getHumanRedeableBytesSize(download.size)}</dd>
      </#if>

      <dt>Status</dt>
      <#if download.isAvailable() && !action.dwcaExists()>
          <dd><@s.text name="enum.downloadstatus.unavailable" />. Please contact <@common.helpdesk/> to restore it.</dd>
      <#else>
          <dd><@s.text name="enum.downloadstatus.${download.status}" /></dd>
      </#if>

      <dt></dt>
      <dd class="small"><@records.dLink download /></dd>
    </dl>
  </div>
</@common.article>

<#-- Shows the dataset information only if download dwcaExists -->
<#if download.isAvailable()>
  <#assign dCount=(page.count)!0/>
  <@common.article id="datasets" title="${dCount} dataset${(dCount > 1)?string('s','')} contributed data to this download" class="results">
    <div class="fullwidth">
      <#if page?? && page.results?has_content && page.count &gt; 0 >
        <#list page.results as du>
          <#assign queryParams=action.getQueryParamsWithoutDataset(du.download.request.predicate)!""/>
          <#if queryParams?has_content>
            <#assign queryParams=queryParams + "&datasetKey=" + du.datasetKey />
          <#else>
            <#assign queryParams="datasetKey=" + du.datasetKey />
          </#if>
          <@records.downloadUsage du=du queryParams=queryParams />
        </#list>
        <div class="footer">
          <@paging.pagination page=page url=currentUrlWithoutPage/>
        </div>
      <#else>
          <p>No dataset information available for this download.</p>
      </#if>
    </div>
  </@common.article>
</#if>


</body>
</html>
