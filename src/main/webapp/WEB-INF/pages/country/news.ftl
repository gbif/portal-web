<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/feeds.ftl" as feeds>
<html>
<head>
  <title>Country News for ${country.title}</title>

  <#include "/WEB-INF/inc/feed_templates.ftl">

  <script type="text/javascript">
      $(function() {
        <#if drupalTagId?has_content>
          <@feeds.drupalTagFeedJs tagId="${drupalTagId}" target="#gbifnews" />
        </#if>
        <#if feed??>
          <@feeds.googleFeedJs url="${feed}" target="#nodenews" />
        </#if>
      });
  </script>
</head>
<body>

<#assign tab="news"/>
<#include "/WEB-INF/pages/country/inc/infoband.ftl">


<#if drupalTagId?has_content>
  <#assign ltitle>News items tagged ${country.title} <a href="${cfg.drupal}/taxonomy/term/${drupalTagId}/feed"><img class="rss" src="<@s.url value='/img/icons/rss-feed.gif'/>" /></a></#assign>
<#else>
  <#assign ltitle="News items tagged ${country.title}"/>
</#if>

<#if feed??>
  <#assign rtitle>News from node <a href="${feed}"><img class="rss" src="<@s.url value='/img/icons/rss-feed.gif'/>" /></a></#assign>
<#else>
  <#assign rtitle="News from node"/>
</#if>

<@common.article id="news" title=ltitle titleRight=rtitle class="results">
    <div id="gbifnews" class="left">
        <p>There are currently no news items tagged ${country.title}.</p>
    </div>

    <div class="right" id="nodenews">
      <#if feed??>
          <p>No news available in feed.</p>
      <#else>
          <p>No node news feed registered.</p>
      </#if>
    </div>
</@common.article>


</body>
</html>
