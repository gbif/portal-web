<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/pagination.ftl" as macro>
<html>
<head>
  <title>Species Search Results for ${q!}</title>

  <content tag="extra_scripts">
    <script type="text/javascript" src="<@s.url value='/js/facets.js'/>"></script>    
    <script type="text/javascript">
      //needed to avoid caching by Firefox's bfcache
      window.onunload = function(){ };
    </script>
  </content>
</head>
<body class="search">
  <content tag="infoband">
    <h1>Search species</h1>

    <form action="<@s.url value='/species/search'/>" method="GET" id="formSearch" >
      <input id="q" type="text" name="q" value="${q!}" autocomplete="off" placeholder="Search scientific name, common name, checklist description..."/>
    <#list searchRequest.parameters.asMap()?keys as p>
      <#list searchRequest.parameters.get(p) as val>
      <input type="hidden" name="${p?lower_case}" value="${val!}"/>
      </#list>
    </#list>
    </form>
  </content>

  <form action="<@s.url value='/species/search'/>" autocomplete="off" >
    <article class="results light_pane">
      <input type="hidden" name="q" value="${q!}"/>
      <header></header>
      <div class="content">
        <div class="header">
          <div class="left">
            <h2>${searchResponse.count!} results <#if q?has_content>for &quot;${q}&quot;</#if></h2>
          </div>
          <div class="right"><h3>Refine your search</h3></div>
        </div>

        <div class="left">

        <#list searchResponse.results as u>

          <#assign vernacular = "" />
          <#if u.vernacularNames?has_content>
            <#assign vernacular = u.vernacularNames[0] />
          </#if>

          <div class="result">
            <h3>
              <#if vernacular?has_content>
                Common Name
              <#elseif u.synonym>
                <#if u.rank??><@s.text name="enum.rank.${u.rank}"/> </#if>
                <@s.text name="enum.taxstatus.SYNONYM"/>
              <#else>
                <@s.text name="enum.taxstatus.ACCEPTED"/>
                <#if u.rank??> <@s.text name="enum.rank.${u.rank}"/></#if>
              </#if>
              <#if showAccordingTo>
                <span>from ${titles.get(u.datasetKey)!"???"}</span>
              </#if>
            </h3>

            <h2>
              <a href="<@s.url value='/species/${u.key?c}'/>">
              <#if vernacular?has_content>
                ${vernacular.vernacularName} <span class="note"> for ${u.scientificName}</span>
              <#else>
                ${u.scientificName} <#if u.synonym && u.accepted??><span class="note"> for ${u.accepted}</span></#if>
              </#if>
              </a>
            </h2>

            <ul class="taxonomy">
              <#assign classification=u.higherClassificationMap />
              <#list classification?keys as usageKey>
                <li<#if !usageKey_has_next> class="last"</#if>>
                  ${classification.get(usageKey)!"???"}
                </li>
              </#list>
            </ul>

            <div class="footer">
              <#list u.descriptions as desc>
                <#if action.isHighlightedText(desc.description)>
                  <p>${action.getHighlightedText(desc.description, 92)}</p>
                  <#break />
                </#if>
              </#list>
            </div>

          </div>
        </#list>

          <div class="footer">
          <@macro.pagination page=searchResponse url=currentUrlWithoutPage/>
          </div>
        </div>


        <div class="right">

          <div id="resetFacets" data-currentUrl="">
            <input id="resetFacetsButton" value="reset" type="button"/>
            <input class="defaultFacet" type="hidden" name="dataset_key" value="${nubDatasetKey}"/>
          </div>

          <#assign seeAllFacets = ["HIGHERTAXON_KEY","RANK","DATASET_KEY", "NOMENCLATURAL_STATUS"]>
          <#assign facets= ["DATASET_KEY","HIGHERTAXON_KEY","RANK","STATUS","EXTINCT","THREAT","HABITAT", "NOMENCLATURAL_STATUS", "NAME_TYPE"]>
          <#include "/WEB-INF/inc/facets.ftl">
        </div>
      </div>
      <footer></footer>
    </article>
  </form>
  <div class="infowindow" id="waitDialog">
    <div class="light_box">
      <div class="content">
        <h3>Processing request</h3>

        <div>Wait while your request is processed...
          <img src="<@s.url value='/img/ajax-loader.gif'/>" alt=""/>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
