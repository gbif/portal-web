<#import "/WEB-INF/macros/pagination.ftl" as paging>
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>
<html>
<head>
  <title>Current GBIF Participants</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
</head>

  <content tag="infoband">
    <h1 class="fullwidth">Participation</h1>
    <h3>Being part of the GBIF community</h3>
  </content>

  <content tag="tabs">
    <ul class="${hl!}">
      <li>
        <a href="${cfg.drupal}/participation/summary" title="Summary"><span>Summary</span></a>
      </li>
      <li>
          <a href="${cfg.drupal}/participation/membership" title="Membership"><span>Membership</span></a>
      </li>
      <li class='selected'>
          <a href="<@s.url value='/participation/list'/>" title="Participant List"><span>Participant List</span></a>
      </li>
      <li>
          <a href="${cfg.drupal}/participation/howtojoin" title="How to join"><span>How to join</span></a>
      </li>
    </ul>
  </content>


<body class="dataset">

  <@common.article title="Overview" titleRight="Quick links">
    <div class="left">
      <p>
        This is a list of all countries, organizations and economies currently participating in GBIF through signature of the Memorandum of Understanding (MoU).
        Click on the name of each Participant to get full contact details, as well as news and information about biodiversity data publication and use.
      </p>
    </div>

      <div class="right">
          <ul>
              <li><a href="#voting">Voting Participants</a></li>
              <li><a href="#associate">Associate Country Participants</a></li>
              <li><a href="#other">Other Associate Participants</a></li>
          </ul>
      </div>
  </@common.article>

<#macro particle id title plist showCountry=false>
  <@common.article id=id title=title titleRight="Metrics">
    <div class="left">
      <#nested>
      <table class="table table-bordered table-striped">
          <thead>
            <tr>
              <#if showCountry>
                <th>Participant</th>
                <th>Node Institution</th>
              <#else>
                <th>Participant</th>
              </#if>
              <th>Member since</th>
            </tr>
          </thead>
          <tbody>
            <#list plist as p>
            <tr>
              <#if showCountry>
                <td><a href="<@s.url value='/country/${p.country.getIso2LetterCode()}/participation'/>">${p.country.title}</a></td>
                <td>
                  <#if p.homepage?has_content>
                    <a href="${p.homepage}">${p.title!}</a>
                  <#else>
                    ${p.title!}
                  </#if>
                </td>
              <#else>
                <#-- TAIWAN HACK, see http://dev.gbif.org/issues/browse/PF-1031 -->
                <td><a href="<@s.url value='/node/${p.key}'/>"><#if common.taiwanNodeKey == p.key>${p.country.title}<#else>${p.title!}</#if></a></td>
              </#if>
              <td><#if p.participantSince??>${p.participantSince?c}</#if></td>
            </tr>
            </#list>
          </tbody>
      </table>
    </div>

    <div class="right">
        <p>${plist?size} ${title}</p>
    </div>
  </@common.article>
</#macro>


  <@particle id="voting" title="Voting Participants" plist=voting showCountry=true>
    <p>
      Countries that have signed the GBIF Memorandum of Understanding and agree to make
      a <a href="${cfg.drupal}/governance/finance">basic financial contribution</a> to GBIF core funds.
    </p>
  </@particle>

  <@particle id="associate" title="Associate Country Participants" plist=associate showCountry=true>
    <p>
      Countries that have signed the GBIF Memorandum of Understanding but do not make a financial contribution to GBIF core funds,
      and do not have a vote on the <a href="${cfg.drupal}/governance/governingboard">GBIF Governing Board</a>.
    </p>
  </@particle>

  <@particle id="other" title="Other Associate Participants" plist=other>
    <p>
      Intergovernmental organizations, international organizations and other organizations with an international scope,
      and economies, that have signed the GBIF Memorandum of Understanding.
    </p>
  </@particle>

</body>
</html>
