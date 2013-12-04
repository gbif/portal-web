<#import "/WEB-INF/macros/common.ftl" as common>

<@common.article id="publishing" class="map" titleRight="Data from ${country.title}">
    <div class="map" id="mapBy"></div>

    <div class="right">
      <ul>
          <li>
            <#if by.occurrenceDatasets gt 0>
              <a href="<@s.url value='/dataset/search?publishingCountry=${country.name()}&type=OCCURRENCE'/>">${by.occurrenceDatasets} occurrence datasets</a>
              <#--
              <@s.url value='/occurrence/search?publishingCountry=${isocode}'/>
              -->
              with <a href="#">${by.occurrenceRecords} records</a>.
            <#else>
              No occurrence datasets.
            </#if>
          </li>

          <li>
            <#if by.checklistDatasets gt 0>
              <a href="<@s.url value='/dataset/search?publishingCountry=${country.name()}&type=CHECKLIST'/>">${by.checklistDatasets} checklists</a>
              with ${by.checklistRecords} records.
            <#else>
              No checklist datasets.
            </#if>
          </li>

          <li>
            <#if by.externalDatasets gt 0>
              <a href="<@s.url value='/dataset/search?publishingCountry=${country.name()}&type=METADATA'/>">${by.externalDatasets} metadata-only datasets</a>.
            <#else>
              No metadata-only datasets.
            </#if>
          </li>

          <li>
            ${country.title} publishes data covering
            <#if by.countries gt 0>
                <a href="<@s.url value='/country/${isocode}/publishing/countries'/>">${by.countries} countries, territories and islands</a>.
            <#else>
              no countries.
            </#if>
          </li>
      </ul>
    </div>
</@common.article>
