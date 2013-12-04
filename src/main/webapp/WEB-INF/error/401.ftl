<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Not Authorised</title>
</head>
<body class="infobandless">

<@common.article class="sorry">
  <h1>Not Authorised</h1>
  <p>You are not authorised for this page.<br/>
  Please <a href="${cfg.drupal}/user/login?destination=${baseUrl}/" title='<@s.text name="menu.login"/>'>login</a> with an admin account.
  </p>
</@common.article>

</body>
</html>
