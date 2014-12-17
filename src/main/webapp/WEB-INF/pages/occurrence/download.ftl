<#import "/WEB-INF/macros/records.ftl" as records>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/pagination.ftl" as paging>
<html>
<head>
  <title>Occurrence Download - GBIF</title>
  <content tag="extra_scripts">
      <script>
          $(document).ready(function() {
              $('tr.rowlink').click(function() {
                  window.location = $(this).data("target");
              });
          });
      </script>
  </content>
</head>
<body class="search">

<content tag="infoband">
  <div class="content">
    <h1>Occurrence download</h1>
    <h3><a href="${download.doi.getUrl()}">${download.doi.getUrl()}</a></h3>
    <h3>${download.created?date?string.medium}</h3>
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
  <@common.notice title="Download runnning">
      <p>Your download has been started and is currently being processed.</p>
      <p>Please expect 10 to 15 minutes for the download to complete. <br/>
         A notification email with a link to download the results will be sent to the following addresses once ready:
      </p>
      <ul>
      <#list download.request.notificationAddresses as email>
          <li>${email}</li>
      </#list>
      </ul>
  </@common.notice>

<#elseif download.isAvailable()>
  <@common.notice title="Query links">
      <p>Live query links below will take you to current results and might differ from the download result presented here.</p>
      <p>Search results will be retained for as long as feasible, but might be deleted in the future.</p>
  </@common.notice>

<#else>
  <@common.notice title="${download.status?capitalize}">
      <p>Your download request was unsuccessful. Please try it again or contact the <a href="mailto:helpdesk@gbif.org">GBIF helpdesk</a>.</p>
  </@common.notice>
</#if>

<@common.article id="details" title="Download details" class="results">
  <div class="fullwidth">
    <#--
    <div class="label"><@common.doi download.doi /></div>
    -->
    <dl>
      <dt>Identifier</dt>
      <dd><@common.doi download.doi /></dd>

      <dt>Filter</dt>
      <dd><@records.dFilter download /></dd>

      <#if download.isAvailable()>
          <dt>Size</dt>
          <dd>${action.getHumanRedeableBytesSize(download.size)}</dd>
      </#if>

      <dt>Status</dt>
      <#if download.status == "SUCCEEDED" && !action.dwcaExists()>
          <dd><@s.text name="enum.downloadstatus.unavailable" /></dd>
      <#else>
          <dd><@s.text name="enum.downloadstatus.${download.status}" /></dd>
      </#if>
    </dl>
  </div>
</@common.article>

<#-- Shows the dataset information only if download dwcaExists -->
<#if download.isAvailable()>
  <#assign dCount=(page.count)!0/>
  <@common.article id="datasets" title="${dCount} dataset${(dCount > 1)?string('s','')} in this download" class="results">
    <div class="fullwidth">
      <#if page?? && page.results?has_content && page.count &gt; 0 >
        <#list page.results as du>
          <@records.downloadUsage downloadUsage=du/>
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
