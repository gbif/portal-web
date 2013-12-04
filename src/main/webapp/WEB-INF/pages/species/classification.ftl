<html>
<head>
  <title>${usage.canonicalOrScientificName!} - complete classification</title>
</head>

<body class="species">

<#assign tab="info"/>
<#assign tabhl=true />
<#include "/WEB-INF/pages/species/inc/infoband.ftl">

  <div class="back">
    <div class="content">
      <a href="<@s.url value='/species/${id?c}'/>" title="Back to species overview">Back to species overview</a>
    </div>
  </div>

  <article class="classification">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <hgroup>
            <h2>${parents?size} taxonomy levels for "${usage.canonicalOrScientificName!"???"}"</h2>

            <h3>According to <a href="<@s.url value='/dataset/${usage.datasetKey}'/>">${dataset.title!"???"}</a></h3>
          </hgroup>
        </div>
      </div>

      <div class="fullwidth">
        <ul class="classification">
        <#assign indent = 10 />
        <#list parents as p>
          <li>
            <span class="taxon_level">${p.rank!}</span>
            <span class="separator" style="width:${indent}px"></span>
            <a href="<@s.url value='/species/${p.key?c}'/>">${p.scientificName!"???"}</a>
          </li>
          <#assign indent = indent + 10 />
        </#list>
        </ul>
      </div>

    </div>
    <footer></footer>
  </article>
</body>
</html>
