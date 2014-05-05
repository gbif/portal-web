<#import "/WEB-INF/macros/common.ftl" as common>

<@common.article id="datasets" title="Latest datasets published">
    <div class="fullwidth">
      <#if datasets?has_content>
        <ul class="notes">
          <#list datasets as cw>
            <#if cw_index==6>
              <li class="more"><a href="<@s.url value='/dataset/search?publishingCountry=${country.name()}'/>">${by.occurrenceDatasets + by.checklistDatasets - 6} more</a></li>
                <#break />
            </#if>
            <@common.datasetListItem title=cw.obj.title key=cw.obj.key type=cw.obj.type modified=cw.obj.modified owningOrganizationKey=cw.obj.owningOrganizationKey owningOrganizationTitle=action.getOrganization(cw.obj.owningOrganizationKey).title count=cw.count geoCount=cw.geoCount></@common.datasetListItem>
          </#list>
        </ul>
      <#else>
        <p>None published.</p>
      </#if>
    </div>
</@common.article>
