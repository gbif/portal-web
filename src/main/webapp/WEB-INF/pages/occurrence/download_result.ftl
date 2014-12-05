<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Occurrence Download - GBIF</title>
</head>
<body class="search">

<content tag="infoband">
    <h1>Occurrence Download</h1>
</content>

<@common.article id="started" title="${pageTitle}">
    <div>
      <#if !action.hasFieldErrors()>
        <!-- cfg.wsOcc is not public, but needed for authentication. Therefore wsOccPublic was created which is public -->
        <#if download.available>
          <!-- cfg.wsOcc is not public, but needed for authentication. Therefore wsOccPublic was created which is public -->
         <p>Your download is ready for <a href="${cfg.wsOccPublic}occurrence/download/request/${download.key}.zip">download</a> since ${download.modified?datetime?string.short_medium}</p>
         <p>This file can be cited by using the DOI <a href="http://doi.org/${download.doi}">${download.doi}</a></p>
         <p>Download information: <#if download.size?has_content>${action.getHumanRedeableBytesSize(download.getSize())} - </#if>
              <#if download.totalRecords?has_content>${download.totalRecords} records - </#if>
              <#if download.numberDatasets?has_content>${download.numberDatasets} datasets</#if>
         </p>
      <#elseif action.isDownloadRunning(download.status)>
          <p>Your <a href="${cfg.wsOccPublic}occurrence/download/${key}">download #${key}</a> is running</p>
          <p>Please expect 10 to 15 minutes for the download to complete. <br/>
           A notification email with a link to download the results will be sent to the following addresses once ready:
            <ul>
              <#list emails as email>
                <li>${email}</li>
              </#list>
            </ul>
          </p>
      <#else>
        <p>Your download status is "<@s.text name="enum.downloadstatus.${download.status}" />"</p>
      </#if>
      <p>In your user home you can also see the status and link to <a href="<@s.url value='/user/download'/>">all your requested downloads</a>.</p>
      <p style="font-size:small;">Please visit this <a href="<@s.url value='/faq/datause'/>">page</a> to obtain information of how to use the downloaded data.</p>
      <#else>
        <p><@s.fielderror fieldName="key"/></p>
      </#if>
    </div>
</@common.article>

</body>
</html>
