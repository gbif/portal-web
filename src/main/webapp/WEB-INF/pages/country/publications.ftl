<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/feeds.ftl" as feeds>
<html>
<head>
  <title>Publications relevant to ${country.title}</title>

  <#include "/WEB-INF/inc/feed_templates.ftl">

  <script type="text/javascript">
      $(function() {
        <@feeds.mendeleyFeedJs isoCode="${isocode}" target="#pubcontent" />
      });
  </script>
</head>
<body>

<#assign tab="publications"/>
<#include "/WEB-INF/pages/country/inc/infoband.ftl">


<@common.article id="publications" title="Uses of GBIF in scientific research">
    <div class="fullwidth">
      <p>
        Peer-reviewed research citing GBIF as a data source, with at least one author from ${country.title}.<br/>
        Extracted from the <a href="http://www.mendeley.com/groups/1068301/gbif-public-library/">Mendeley GBIF Public Library</a>.
      </p>
    </div>
</@common.article>

<@common.article class="nohead">
    <div id="pubcontent" class="fullwidth">
        <p>There are no publications known for ${country.title}.</p>
    </div>
</@common.article>


</body>
</html>
