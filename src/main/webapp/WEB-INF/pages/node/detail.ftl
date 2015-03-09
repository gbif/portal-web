<#-- @ftlvariable name="" type="org.gbif.portal.action.node.NodeAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>
<#include "/WEB-INF/pages/node/inc/title.ftl">
<html>
<head>
    <title>${title} - ${subtitle} | GBIF.ORG</title>

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
  <@common.article id="summary" title="About" titleRight="" fullWidthTitle=true>
      <div class="fullwidth">
        <p>
          The Participant Node Managers Committee is a body that can endorse an institution to publish data through the GBIF network.
          Wherever possible, a national Node or thematic network is preferred to endorse an institution to help ensure the most relevant technical and administrative support is given.
          In the absence of such a suitable Node the committee can endorse publishers.
          To request endorsement please contact the <@common.helpdesk />.
        </p>
      </div>
  </@common.article>
<#else>
  <#include "/WEB-INF/pages/node/inc/participation.ftl">
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


<@common.article id="publishers" title="Endorsed publishers">
    <div class="fullwidth">
      <#if publisherPage.results?has_content>
          <ul class="notes">
            <#list publisherPage.results as pub>
              <@records.publisher publisher=pub />
            </#list>
            <#if !publisherPage.endOfRecords>
                <li class="more">
                ${publisherPage.count - publisherPage.limit}
                  <#if country??>
                      <a href="<@s.url value='/country/${isocode}/publishers'/>">more</a>
                  <#else>
                      <a href="<@s.url value='/node/${member.key}/publishers'/>">more</a>
                  </#if>
                </li>
            </#if>
          </ul>
      <#else>
          <p>None endorsed.</p>
      </#if>

    </div>
</@common.article>

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
