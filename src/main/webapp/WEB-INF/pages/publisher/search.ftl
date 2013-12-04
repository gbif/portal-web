<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/pagination.ftl" as macro>
<html>
<head>
  <title>Publisher search</title>
  <content tag="extra_scripts"></content>
</head>
<body class="search">
  <content tag="infoband">
    <h1>Search data publishers</h1>
    <form action="<@s.url value='/publisher/search'/>" method="GET" id="formSearch" >
      <input id="q" type="text" name="q" value="${q!}" autocomplete="off" placeholder="Search by publisher title, country, contact email etc."/></br>
    </form>
  </content>

<@common.notice title="">
  <p>Results are ordered by the date of publisher registration, starting with the most recent.<br/>
      Newly registered institutions yet to publish data, or awaiting endorsement, may be included in the results.</p>
</@common.notice>


  <#assign title>
  ${page.count!} results <#if q?has_content>for &quot;${q}&quot;</#if>
  </#assign>
  <@common.article class="results" title=title>
    <div class="fullwidth">
    <#assign max_show_length = 68>
    <#list page.results as pub>
        <div class="result">
          <#if pub.logoUrl?has_content>
            <div class="logo_holder">
              <img src="<@s.url value='${pub.logoUrl}'/>"/>
            </div>
          </#if>

          <h2>
            <a href="<@s.url value='/publisher/${pub.key}'/>" title="${pub.title!}">${pub.title!}</a>
          </h2>

          <p>A data publisher
            <#-- country can appear on its own, but if city appears, there must be a country too -->
            <@common.cityAndCountry pub/>
            <#if (pub.numOwnedDatasets > 0)>with ${pub.numOwnedDatasets} published datasets</#if>
          </p>

          <div class="footer">
            <#if pub.endorsementApproved>
              <p>Endorsed by <a href="<@s.url value='/node/${pub.endorsingNodeKey}'/>">${(nodeIndex.get(pub.endorsingNodeKey).title)!""}</a></p>
            <#else>
              <p>Not endorsed yet</p>
            </#if>
          </div>
        </div>
    </#list>

      <div class="footer">
        <@macro.pagination page=page url=currentUrlWithoutPage />
      </div>
    </div>

  </@common.article>

</body>
</html>