<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<html xmlns="http://www.w3.org/1999/html" xmlns="http://www.w3.org/1999/html">
<head>
  <title>Your Name Lists</title>
  <style type="text/css">
      .result table th {
          font-variant: small-caps;
          padding-right: 10px;
      }
      .result table tr {
          padding-top: 5px;
      }
  </style>
</head>

<body class="newsroom">

<#assign tab="namelists"/>
<#include "/WEB-INF/pages/user/inc/infoband.ftl">

  <@common.article title="Your Name Lists" class="results">
    <div class="fullwidth">
        <p class="note">Personal species name lists are coming soon, we are working hard...</p>
    </div>
  </@common.article>

</body>
</html>
