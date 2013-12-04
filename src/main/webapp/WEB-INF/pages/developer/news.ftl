<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>GBIF News API</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
</head>

<#assign tab="news"/>
<#include "/WEB-INF/pages/developer/inc/tabs.ftl" />

<body class="api">


<@api.introArticle>
<div class="left">
    <p>
        This API is used to retrieve <a href="${cfg.drupal}/newsroom/news">news</a> or publications from or about GBIF.
    </p>
</div>
<div class="right">
    <ul>
        <li><a href="#news">GBIF news</a></li>
        <li><a href="#mendeley">Mendeley publications</a></li>
    </ul>
</div>
</@api.introArticle>

<@api.article id="news" title="GBIF news">
  <p>GBIF provides RSS feeds for all news or the subset relevant to a specific country.
  These feeds are currently not accessible through the API and are linked from the respective country pages,
  for example the <a href="<@s.url value='/country/ES/news'/>">Spanish news</a>.
  </p>
</@api.article>


<@api.article id="news" title="Mendeley">
  <p>GBIF maintains a <a href="http://www.mendeley.com/groups/1068301/gbif-public-library/">Mendeley group</a>
     sharing publications relevant to the Global Biodiversity Information Facility.
     They are tagged according to whether data accessed via GBIF are used in research,
     or whether GBIF is discussed/mentioned, as well as subjects covered and countries of contributing authors.
  </p>

  <@api.apiTable auth=false>
    <@api.trow url="/mendeley/country/{ISOCODE}" httpMethod="GET" resp="PublicationList" respLink="/mendeley/country/FR" authRequired="" paging=false>Publications tagged with a given country</@api.trow>
  </@api.apiTable>
</@api.article>

</body>
</html>