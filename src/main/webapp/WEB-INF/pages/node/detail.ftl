<#-- @ftlvariable name="" type="org.gbif.portal.action.node.NodeAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Node detail of ${node.title}</title>
<#include "/WEB-INF/inc/feed_templates.ftl">
  <script type="text/javascript">
    $(function() {
      <#if feed??>
        <@common.googleFeedJs url="${feed}" target="#news" />
      </#if>
    });
  </script>
</head>
<body class="species">

<#assign tab="info"/>
<#include "/WEB-INF/pages/node/inc/infoband.ftl">

<#--
  The Participant Node Managers Committee
  is an entity that is used to endorse publishers who otherwise would struggle to find
  an endorsing node.  It is considered a persistent stable id.
-->
<#if node.key == common.participantNMCKey>
  <#include "/WEB-INF/pages/node/inc/committee.ftl">
<#else>
  <#include "/WEB-INF/pages/country/inc/participation.ftl">
  <#if node.contacts?has_content>
    <#assign rtitle><span class="showAllContacts small">show all</span></#assign>
    <@common.article id="contacts" title="Contacts" titleRight=rtitle>
      <div class="fullwidth">
        <#if node.contacts?has_content>
        <@common.contactList node.contacts />
      </#if>
      </div>
    </@common.article>
  </#if>
</#if>


<#include "/WEB-INF/pages/country/inc/endorsing_article.ftl">


<#if feed??>
   <#assign titleRight = "News" />
 <#else>
   <#assign titleRight = "" />
 </#if>
<@common.article id="latest" title="Latest datasets published" titleRight=titleRight>
    <div class="<#if feed??>left<#else>fullwidth</#if>">
      <#if datasets?has_content>
        <ul class="notes">
          <#list datasets as cw>
            <@common.datasetListItem title=cw.obj.title key=cw.obj.key type=cw.obj.type modified=cw.obj.modified publishingOrganizationKey=cw.obj.publishingOrganizationKey publishingOrganizationTitle=action.getOrganization(cw.obj.publishingOrganizationKey).title count=cw.count geoCount=cw.geoCount></@common.datasetListItem>
          </#list>
        </ul>
      <#else>
        <p>None published.</p>
      </#if>
    </div>

  <#if feed??>
    <div class="right">
        <div id="news"></div>
    </div>
  </#if>
</@common.article>

</body>
</html>
