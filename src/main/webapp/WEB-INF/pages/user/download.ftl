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

  <@common.article title="Your Downloads" class="results">
    <div class="fullwidth">
      <#if !page.results?has_content>
        <p>You did not download any data so far.</p>
      </#if>

      <#list page.results as download>
          <@records.downloadFilter download=download showCancel=true />
      </#list>

      <div class="footer">
        <@paging.pagination page=page url=currentUrlWithoutPage/>
        <p style="font-size:small;">Please visit this <a href="<@s.url value='/faq/datause'/>">page</a> to obtain information of how to use the downloaded data.</p>
      </div>
    </div>
  </@common.article>

</body>
</html>
