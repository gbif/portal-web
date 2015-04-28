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
  </div>
</content>

<@common.notice title="Forbidden download">
    <p>Your download request has been denied.</p>
    <p>You have ${downloads.count} downloads running which reached the maximum number of simultaneous downloads allowed.</p>
    <p>Please wait until one of your downloads finishes to try it again.</p>
</@common.notice>

</body>
</html>
