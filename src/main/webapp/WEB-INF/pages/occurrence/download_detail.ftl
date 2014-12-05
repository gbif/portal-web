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
    <h1>Occurrence Download</h1>
  </div>
  <#if action.showDownload()>
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
<@common.article id="details" title="Download details" class="results">
  <div class="fullwidth">
  <#-- Shows the information if the download exists -->
  <#if !action.hasFieldErrors() && download??>
    <@records.downloadFilter download=download showCancel=false showStatus=false>
      <#if download.size??>
        <dt>Size</dt>
        <dd>${action.getHumanRedeableBytesSize(download.getSize())}</dd>
      </#if>
      <#if action.isDownloadRunning(download.status)></p>
        <dt>Status</dt>
        <dd><@s.text name="enum.downloadstatus.${download.status}" /></dd>
        <dt>&nbsp;</dt>
        <dd>
          <p>The <a href="${cfg.wsOccPublic}occurrence/download/${key}">download #${key}</a> is not ready.</p>
          <p>Please expect 10 to 15 minutes for the download to complete.</p>
        </dd>
      <#elseif download.status != 'SUCCEEDED'>
        <dt>Status</dt>
        <dd><@s.text name="enum.downloadstatus.${download.status}" /></dd>
      </#if>
    </@records.downloadFilter>
  <#else>
    <#-- Shows the error message -->
    <p><@s.fielderror fieldName="key"/></p>
  </#if>
  </div>
</@common.article>

<#-- Shows the information if the download exists -->
<#if !action.hasFieldErrors() && download??>
  <#if page??>
    <#assign datasetsTitle="${page.count} dataset${(page.count > 1)?string('s','')} in this download"/>
  <#else>
    <#assign datasetsTitle="0 datasets in this download"/>
  </#if>
  <@common.article id="datasets" title=datasetsTitle class="results">
      <div>
        <div class="fullwidth">
          <#if page?? && page.results?has_content && page.count &gt; 0 >
            <#list page.results as du>
              <@records.downloadUsage downloadUsage=du/>
            </#list>
            <div class="footer">
              <@paging.pagination page=page url=currentUrlWithoutPage/>
            </div>
          <#else>
            <p>No datasets information available for this download.</p>
          </#if>
        </div>
      </div>
  </@common.article>
</#if>
</body>
</html>
