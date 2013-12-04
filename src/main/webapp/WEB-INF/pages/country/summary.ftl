<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/feeds.ftl" as feeds>
<html>
<head>
  <title>Country Summary for ${country.title}</title>
  <link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.css'/>" />
  <!--[if lte IE 8]><link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.ie.css'/>" /><![endif]-->
  <script type="text/javascript" src="<@s.url value='/js/vendor/leaflet/leaflet.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/map.js'/>"></script>
<#include "/WEB-INF/inc/feed_templates.ftl">

  <script type="text/javascript">
      $(function() {
          $("#mapAbout").append(
            '<iframe id="mapAboutFrame" name="map" src="${cfg.tileServerBaseUrl!}/index.html?type=COUNTRY&key=${isocode}" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>'
          );
                    
          $("#mapBy").append(
            '<iframe id="mapByFrame" name="map" src="${cfg.tileServerBaseUrl!}/index.html?type=PUBLISHING_COUNTRY&key=${isocode}" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>'
          );

          <#if feed??>
            <@feeds.googleFeedJs url="${feed}" target="#news" />
          </#if>
      });
  </script>
</head>
<body>

<#assign tab="summary"/>
<#include "/WEB-INF/pages/country/inc/infoband.ftl">


<#include "/WEB-INF/pages/country/inc/about_article.ftl">

<#if datasets?has_content>
  <#include "/WEB-INF/pages/country/inc/publishing_article.ftl">
</#if>

<#include "/WEB-INF/pages/country/inc/participation.ftl">

<#include "/WEB-INF/pages/country/inc/latest_datasets_article.ftl">


</body>
</html>
