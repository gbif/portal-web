<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>
<html xmlns="http://www.w3.org/1999/html" xmlns="http://www.w3.org/1999/html">
<head>
  <title>Your Downloads</title>
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

<body class="newsroom">

<#assign tab="download"/>
<#include "/WEB-INF/pages/user/inc/infoband.ftl">

  <@common.article title="Your downloads" class="results">
    <div class="fullwidth">
      <#if !page.results?has_content>
        <p>You did not download any data so far.</p>
      </#if>

      <#list page.results as download>
        <div class="result">
          <div class="footer">
            <dl>
                <dt>Download</dt>
                <dd><@common.doilink doi=download.doi url="/occurrence/download/${download.key}" /> ${niceDate(download.created)}</dd>

                <dt>Query</dt>
                <dd><@records.dFilter download /></dd>

                <dt>Status</dt>
                <dd>
                  <#if download.available>
                    <#if action.dwcaExists(download)>
                        Ready for <a href="${download.downloadLink}">download</a>
                    <#else>
                        <@s.text name="enum.downloadstatus.unavailable" />
                    </#if>
                    <#if download.size?has_content>(${action.getHumanRedeableBytesSize(download.getSize())} </#if>
                    <#if download.totalRecords?has_content>${download.totalRecords} records - </#if>
                    <#if download.numberDatasets?has_content>${download.numberDatasets} datasets)</#if>

                  <#elseif action.isRunning(download)>
                      Still running. Do you want to <a href="<@s.url value='/user/download/cancel?key=${download.key}'/>">cancel</a> the query?
                  <#else>
                    <@s.text name="enum.downloadstatus.${download.status}" />
                  </#if>
                </dd>

                <dt></dt>
                <dd class="small"><@records.dLink download /></dd>
            </dl>
          </div>
        </div>
      </#list>

      <div class="footer">
        <@paging.pagination page=page url=currentUrlWithoutPage/>
        <p style="font-size:small;">Please visit this <a href="<@s.url value='/faq/datause'/>">page</a> to obtain information of how to use the downloaded data.</p>
      </div>
    </div>
  </@common.article>

</body>
</html>
