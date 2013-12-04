<#import "/WEB-INF/macros/common.ftl" as common>

<@common.article id="about" class="map" titleRight="Data about ${country.title}">
    <div class="map" id="mapAbout"></div>

    <div class="right">
      <ul>
          <li>
            <#if about.occurrenceDatasets gt 0>
              <a href="<@s.url value='/country/${isocode}/about/datasets'/>">${about.occurrenceDatasets} occurrence datasets</a>
              with <a href="<@s.url value='/occurrence/search?country=${isocode}'/>">${about.occurrenceRecords} records</a>.
            <#else>
              No occurrence datasets
            </#if>
          </li>

          <li>
            <#if about.checklistDatasets gt 0>
              <#--
              <@s.url value='/dataset/search?country=${isocode}&type=CHECKLIST'/>
              -->
              <a href="#">${about.checklistDatasets} checklists</a>
              with ${about.checklistRecords} records.
            <#else>
              No checklists.
            </#if>
          </li>

          <li>
            <#if about.externalDatasets gt 0>
              <a href="<@s.url value='/dataset/search?country=${isocode}&type=METADATA'/>">${about.externalDatasets} metadata-only datasets</a>
            <#else>
              No metadata-only datasets
            </#if>
              relevant to ${country.title}.
          </li>

          <li>
              <#if about.countries gt 0>
                  <a href="<@s.url value='/country/${isocode}/about/countries'/>">${about.countries} countries</a>
              <#else>
                  No countries
              </#if>
               contribute data about ${country.title}.
          </li>
      </ul>
    </div>
</@common.article>