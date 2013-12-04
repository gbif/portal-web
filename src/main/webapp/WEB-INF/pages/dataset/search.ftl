<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/pagination.ftl" as macro>
<html>
<head>
  <title>Dataset Search Results for ${q!}</title>
  <content tag="extra_scripts">
    <script type="text/javascript" src="<@s.url value='/js/facets.js'/>">
    </script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-ui-1.8.17.min.js'/>"></script>
      <script type="text/javascript" src="<@s.url value='/js/portal_autocomplete.js'/>"></script>
      <script>
        $("#q").datasetAutosuggest(cfg.wsRegSuggest, 6, 130, "#content", function(item){ window.location = cfg.baseUrl + "/dataset/" + item.key;});
      </script>
  </content>
</head>


<body class="search">
  <content tag="infoband">
    <h1>Search datasets</h1>
    <form action="<@s.url value='/dataset/search'/>" method="GET" id="formSearch">
      <input type="text" name="q" id="q" value="${q!}" class="focus" placeholder="Search title, description, publisher..."/>
      <#list searchRequest.parameters.asMap()?keys as p>
        <#list searchRequest.parameters.get(p) as val>
        <input type="hidden" name="${p}" value="${val!}"/>
        </#list>
      </#list>
    </form>
  </content>

  <form action="<@s.url value='/dataset/search'/>" autocomplete="off">
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

      <#assign max_show_length = 68>
      <#list searchResponse.results as dataset>
        <div class="result">
          <h3><@s.text name="enum.datasettype.${dataset.type!'UNKNOWN'}"/></h3>

          <h2>
            <#assign datasetTitle = action.addMissingHighlighting(dataset.title!, "${q!}")>
            <a href="<@s.url value='/dataset/${dataset.key!}'/>" title="${action.removeHighlighting(datasetTitle!)}">${action.limitHighlightedText(datasetTitle!, max_show_length)}</a>
          </h2>

          <#if dataset.owningOrganizationKey?has_content>
            <p>
              <#if recordCounts.get(dataset.key)??>
                ${recordCounts.get(dataset.key)} records published by
              <#else>
                Published by
              </#if>
              <a href="<@s.url value='/publisher/${dataset.owningOrganizationKey}'/>" title="${action.removeHighlighting(dataset.owningOrganizationTitle!)}">${dataset.owningOrganizationTitle!"Unknown"}</a></p>
          <#elseif dataset.hostingOrganizationKey?has_content>
            <p>Hosted by <a href="<@s.url value='/publisher/${dataset.hostingOrganizationKey}'/>" title="${action.removeHighlighting(dataset.hostingOrganizationTitle!)}">${dataset.hostingOrganizationTitle!"Unknown"}</a></p>
          </#if>

          <!-- iterate through keywords and generate concatenated string composed of highlighted text in keywords -->
          <#if dataset.keywords??>
            <#assign highlightedKeywords = "">
            <#list dataset.keywords as keyword>
              <#if keyword?has_content>
                <#if action.isHighlightedText(keyword)>
                  <#assign highlightedKeywords = highlightedKeywords + action.getHighlightedText(keyword, 20) + " ">
                </#if>
              </#if>
            </#list>
            <!-- display highlighted text in keywords -->
            <#if highlightedKeywords?has_content>
              <p>
                Keywords: ${common.limit(highlightedKeywords,max_show_length)}
              </p>
            </#if>
          </#if>

          <!-- in footer, display either highlighted text in description, or fact that match only occurred on full text field -->
          <div class="footer">
            <#if dataset.description??>
              <#if action.isHighlightedText(dataset.description)>
                <p>${action.getHighlightedText(dataset.description, max_show_length)}</p>
              </#if>
            </#if>
            <#if action.isFullTextMatchOnly(dataset, q)>
              <#-- we verify asynchroneously via app.js all links with class=verify and hide the list element in case of errors or 404 -->
              <ul>
                <li class="download verify">Search matched <a href="${cfg.wsReg}dataset/${dataset.key}/document">Cached EML</a></li>
              </ul>
            </#if>
          </div>

        </div>
      </#list>

        <div class="footer">
          <@macro.pagination page=searchResponse url=currentUrlWithoutPage/>
        </div>
      </div>



      <div class="right">

        <div id="resetFacets" currentUrl="">
          <input id="resetFacetsButton" value="reset" type="button"/>
        </div>

      <#assign seeAllFacets = ["OWNING_ORG", "HOSTING_ORG", "KEYWORD", "PUBLISHING_COUNTRY", "COUNTRY", "DECADE"]>
      <#assign facets= ["TYPE", "SUBTYPE", "KEYWORD", "OWNING_ORG", "HOSTING_ORG", "PUBLISHING_COUNTRY", "COUNTRY", "DECADE"]>
      <#include "/WEB-INF/inc/facets.ftl">

      </div>
    </div>
    <footer></footer>
  </article>
  </form>
  <div class="infowindow" id="waitDialog">
	  <div class="light_box">
		  <div class="content" >
		    <h3>Processing request</h3>
		    <p>Wait while your request is processed...
		    <img src="<@s.url value='/img/ajax-loader.gif'/>" alt=""/>
		  </div>
	  </div>
   </div>
</body>
</html>
