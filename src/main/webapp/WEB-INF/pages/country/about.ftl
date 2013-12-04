<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>
<#import "/WEB-INF/macros/occ_metrics.ftl" as metrics>
<html>
<head>
  <title>Data About ${country.title}</title>
    <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
    <link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.css'/>" />
    <!--[if lte IE 8]><link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.ie.css'/>" /><![endif]-->
    <script type="text/javascript" src="<@s.url value='/js/vendor/leaflet/leaflet.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/map.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/occ_metrics.js'/>"></script>
    <script type="text/javascript">
        $(function() {
          $("#mapAbout").append(
            '<iframe id="mapAboutFrame" name="map" src="${cfg.tileServerBaseUrl!}/index.html?type=COUNTRY&key=${isocode}" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>'
          );
        });
    </script>
</head>
<body>

<#assign tab="about"/>
<#include "/WEB-INF/pages/country/inc/infoband.ftl">

<#include "/WEB-INF/pages/country/inc/about_article.ftl">

<@common.article id="datasets" title="Largest occurrence datasets about ${country.title}">
  <div class="fullwidth">
    <#if datasets?has_content>
      <ul class="notes">
      <#list datasets as cw>
        <#if cw_index==6>
            <li class="more"><a href="<@s.url value='/country/${isocode}/about/datasets'/>">${about.occurrenceDatasets - 6} more</a></li>
            <#break />
        </#if>
          <li>
            <a title="${cw.obj.title}" href="<@s.url value='/dataset/${cw.obj.key}'/>">${common.limit(cw.obj.title, 100)}</a>
            <span class="note">${cw.count} occurrences out of ${cw.geoCount} <#if cw.geoCount gt 0>(${100.0 * cw.count / cw.geoCount} %)</#if></span>
          </li>
      </#list>
      </ul>
    <#else>
      <p>None.</p>
    </#if>
  </div>
</@common.article>

<@common.article id="countries" title="Countries, territories or islands publishing data about ${country.title}" fullWidthTitle=true>
  <div class="fullwidth">
    <#if countries?has_content>
      <ul>
      <#list countries as cw>
        <#if cw_index==6>
            <li class="more"><a href="<@s.url value='/country/${isocode}/about/countries'/>">${about.countries - 6} more</a></li>
            <#break />
        </#if>
          <li>
            <a title="${cw.obj.getTitle()}" href="<@s.url value='/country/${cw.obj.getIso2LetterCode()}/publishing'/>">${cw.obj.getTitle()}</a>
            <span class="note"> ${cw.count} occurrences<#if cw.geoCount gt 0>, ${100.0 * cw.geoCount / cw.count} % georeferenced</#if>.</span>
          </li>
      </#list>
      </ul>
    <#else>
      <p>None.</p>
    </#if>
  </div>
</@common.article>

<@common.article id="metrics" title="Occurrences located in ${country.title}">
    <div class="fullwidth">
      <p>
        <@metrics.metricsTable baseAddress="country=${country}"/>
	  </p>
    </div>
</@common.article>


</body>
</html>
