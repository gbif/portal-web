<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/records.ftl" as records>

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