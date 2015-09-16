<#-- @ftlvariable name="" type="org.gbif.portal.action.species.DatasetAction" -->
<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<html xmlns="http://www.w3.org/1999/html">
<head>
  <title>Datasets with ${usage.canonicalOrScientificName!}</title>
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

  <article class="results">
    <header></header>
    <div class="content">

      <div class="header">
        <div class="left">
          <h2><em>${usage.canonicalOrScientificName!}</em> appears in:</h2>
        </div>
      </div>

      <div class="fullwidth">

      <#list page.results as item>
        <#-- be conservative and check if dataset actually exists. When registry is out of sync with clb we might see occasional nulls here! -->
        <#if item.dataset??>
          <#assign ds = item.dataset/>
          <#-- be defensive, we have checklists with occurrences: http://dev.gbif.org/issues/browse/POR-614 -->
          <#if ds.type=="CHECKLIST" && item.usage??>
            <#assign linkSpecies = true />
            <#assign link = '/species/${item.usage.key?c}'/>
          <#else>
            <#assign linkSpecies = false />
            <#assign link = '/occurrence/search?taxon_key=${usage.nubKey?c}&dataset_key=${ds.key}' />
          </#if>

            <div class="result">
                <h2><strong><a title="${ds.title!}" href="<@s.url value='${link}'/>">${common.limit(ds.title!, 100)}</a></strong></h2>
                <div class="footer">
                  <#if linkSpecies>
                      as <em>${item.usage.scientificName}</em>
                  <#else>
                    <@s.text name="enum.datasettype.${ds.type!'UNKNOWN'}"/>
                      with ${item.numOccurrences} records of <em>${usage.canonicalOrScientificName!}</em>
                  </#if>
                </div>
            </div>
        </#if>
      </#list>

      <div class="footer">
        <@paging.pagination page=page url=currentUrlWithoutPage/>
      </div>

      </div>

    </div>
    <footer></footer>
  </article>

</body>
</html>
