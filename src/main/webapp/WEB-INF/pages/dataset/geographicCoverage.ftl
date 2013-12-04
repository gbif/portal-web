<html>
<head>
  <title>${dataset.title} - Geographic coverages</title>
</head>
<body>
  <#-- Set up the tabs to highlight the info tab, and includ a backlink -->
  <#assign tab="info"/>
  <#assign tabhl=true />
  <#include "/WEB-INF/pages/dataset/inc/infoband.ftl">
  <div class="back">
    <div class="content">
      <a href="<@s.url value='/dataset/${id}'/>" title="Back to dataset overview">Back to dataset overview</a>
    </div>
  </div>
  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2>Geographic coverage</h2>
        </div>
      </div>

      <div class="fullwidth">
        <#list dataset.geographicCoverages as geo>
          <p>${geo.description!}</p>
        </#list>
      </div>
    </div>
    <footer></footer>
  </article>
</body>
</html>