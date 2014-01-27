<#import "/WEB-INF/macros/common.ftl" as common>
<#assign showMap=occ.longitude?? && occ.latitude??/>
<html>
<head>
  <title>Occurrence Detail ${id?c}</title>
<#-- RDFa -->
  <meta property="dwc:scientificName" content="${occ.scientificName!}"/>
  <meta property="dwc:kingdom" content="${occ.kingdom!}"/>
  <#if dataset.key??>
  <meta property="dwc:datasetID" content="${dataset.key!}"/>
  <meta property="dwc:datasetName" content="${dataset.title!}"/>
  <meta rel="dc:isPartOf" href="<@s.url value='/dataset/${dataset.key}'/>"/>
  </#if>
</head>
<body class="pointmap">

<#assign tab="info"/>
<#include "/WEB-INF/pages/occurrence/inc/infoband.ftl">

<#if showMap>
  <#assign title=""/>
  <#assign titleRight="Location"/>
<#else>
  <#assign title="Location"/>
  <#assign titleRight=""/>
</#if>

<#-- Creates a column list of terms, defaults to 2 columns -->
<#macro vList verbatimGroup exclude title="" columns=2>

  <#-- Are there terms that are not in exclude list? -->
  <#assign show = false/>
  <#list verbatimGroup?keys as term>
    <#if !exclude?seq_contains(term) && verbatimGroup.get(term)??>
      <#assign show = true/>
    </#if>
  </#list>

  <#if show>
  <div class="fullwidth">

    <#assign shown = 0/>
    <#list verbatimGroup?keys as term>
      <#-- do not show terms as listed in the exclude array -->
      <#if !exclude?seq_contains(term) && verbatimGroup.get(term)??>

        <#if shown%columns==0>
          <div class="row col${columns}">
        </#if>
        <div class="contact">
          <div class="contactType">
            ${term}
          </div>
          <div class="value">${verbatimGroup.get(term)}</div>
          <#if shown%columns==columns-1 || !term_has_next >
            <#-- end of row -->
            </div>
          </#if>
          </div>
    <#assign shown = shown + 1/>
    </#if>
  </#list>
  </div>
  </#if>

</#macro>

<#macro citationArticle bibliographicCitation dataset publisher rights accessRights rightsHolder prefix="">
  <@common.article id="legal" title="Citation and licensing" class="mono_line">
  <div class="fullwidth">

    <#-- Show the record citation (DwC term bibliographic citation).
    If there is no record citation, show the dataset citation if it exists, plus the default dataset citation -->
    <#if bibliographicCitation?has_content>
        <h3>Bibliographic Citation</h3>
        <p>${bibliographicCitation}</p>
    <#else>
      <#if dataset.citation?? && !dataset.citation.text!?ends_with(dataset.title)>
          <p>The content  of the "Dataset citation provided by the publisher" depends on the metadata supplied by the publisher.
              In some cases this may be incomplete.  A standard default form for citing is provided as an alternative.
              We are in transition towards providing more consistent citation text for all datasets.
          </p>

          <h3>Dataset citation provided by publisher</h3>
          <p>${dataset.citation.text}</p>
      </#if>

        <h3>Default citation</h3>
        <p>${prefix!}<#if publisher??>${publisher.title}:</#if>
        ${dataset.title}<#if dataset.pubDate?has_content>, ${dataset.pubDate?date?iso_utc}</#if>.
            <br/>Accessed via ${currentUrl} on ${.now?date?iso_utc}
        </p>
    </#if>

    <#if rights?has_content>
        <h3>Rights</h3>
        <p>${rights}</p>
    </#if>

    <#if accessRights?has_content>
        <h3>Access Rights</h3>
        <p>${accessRights}</p>
    </#if>

      <#if rightsHolder?has_content>
          <h3>Rights holder</h3>
          <p>${rightsHolder}</p>
      </#if>

  </div>
  </@common.article>
</#macro>

<#assign locality = action.retrieveTerm('locality')! />

<#-- TOTO: needed to work with mock occurrence page, and since there are still css problems -->
<#if id == -1000000000>
  <#assign mapClass = "occurrenceMap" />
<#else>
  <#assign mapClass = "map" />
</#if>

<@common.article id="location" title=title titleRight=titleRight class=mapClass>
  <#if showMap>
    <div id="map" class="map">
      <iframe id="mapframe" name="mapframe" src="${cfg.tileServerBaseUrl!}/point.html?&style=grey-blue&point=${occ.latitude?c},${occ.longitude?c}&lat=${occ.latitude?c}&lng=${occ.longitude?c}&zoom=8" height="100%" width="100%" frameborder="0"/></iframe>
    </div>
    <div class="right">

      <#if occ.continent??>
        <h3>Continent</h3>
        <p><@s.text name="enum.continent.${occ.continent!'UNKNOWN'}"/></p>
      </#if>

      <#if occ.country??>
        <h3>Country</h3>
        <p><a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></p>
      </#if>

      <#if occ.stateProvince??>
        <h3>State/Province</h3>
        <p>${occ.stateProvince}</p>
      </#if>

      <#if occ.county??>
        <h3>County</h3>
        <p>${occ.county}</p>
      </#if>

      <#if occ.waterBody??>
        <h3>Water Body</h3>
        <p>${occ.waterBody}</p>
      </#if>

      <h3>Locality</h3>
        <p class="no_bottom">${locality!}<#if occ.country??>, <a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></#if></p>
        <p class="light_note">${occ.longitude}, ${occ.latitude}</p>

      <#if occ.coordinateAccuracy??>
        <h3>Coordinate Accuracy</h3>
        <p>${occ.coordinateAccuracy?string}</p>
      </#if>

      <#if occ.geodeticDatum??>
        <h3>Geodetic Datum</h3>
        <p>${occ.geodeticDatum}</p>
      </#if>

  <#else>
    <div class="fullwidth">
    <#if occ.continent??>
        <h3>Continent</h3>
        <p><@s.text name="enum.continent.${occ.continent!'UNKNOWN'}"/></p>
    </#if>

    <#if occ.country??>
        <h3>Country</h3>
        <p><a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></p>
    </#if>

    <#if occ.stateProvince??>
        <h3>State/Province</h3>
        <p>${occ.stateProvince}</p>
    </#if>

    <#if occ.county??>
        <h3>County</h3>
        <p>${occ.county}</p>
    </#if>

    <#if occ.waterBody??>
        <h3>Water Body</h3>
        <p>${occ.waterBody}</p>
    </#if>

    <#if locality?has_content>
        <h3>Locality</h3>
        <p>${locality}</p>
    </#if>
  </#if>

    <#if occ.altitude??>
      <h3>Altitude</h3>
      <p>${occ.altitude}m<#if occ.altitudeAccuracy??> ± ${occ.altitudeAccuracy?string}</#if></p>
    </#if>

    <#if occ.depth??>
      <h3>Depth</h3>
      <p>${occ.depth}m<#if occ.depthAccuracy??> ± ${occ.depthAccuracy?string}</#if></p>
    </#if>

   </div>

<#-- show different set of verbatim terms, depending on whether a map is shown or not. Never show verbatim terms that
are expected to be interpreted -->
<#if verbatim["Location"]??>
      <#if showMap>
        <@vList verbatimGroup=verbatim["Location"] title="Additional location terms" exclude=["continent",
    "stateProvince", "countryCode", "country", "county", "maximumDepthInMeters", "minimumDepthInMeters",
    "maximumElevationInMeters", "minimumElevationInMeters", "locality", "decimalLatitude", "decimalLongitude",
    "verbatimLatitude", "verbatimLongitude", "verbatimDepth", "verbatimElevation", "verbatimLocality",
    "verbatimCoordinates", "verbatimCoordinateSystem", "coordinatePrecision", "coordinateUncertaintyInMeters",
    "geodeticDatum", "waterBody"] />
      <#else>
        <@vList verbatimGroup=verbatim["Location"] title="Additional location terms" exclude=["continent",
    "stateProvince", "countryCode", "country", "county", "maximumDepthInMeters", "minimumDepthInMeters",
    "maximumElevationInMeters", "minimumElevationInMeters", "locality", "verbatimElevation", "verbatimLocality",
    "waterBody"] />
      </#if>
</#if>

</@common.article>

<@common.article id="source" title="Source details">
    <div class="left">
      <h3>Data publisher</h3>
      <p>
        <a href="<@s.url value='/publisher/${publisher.key}'/>" title="">${publisher.title}</a>
      </p>

      <h3>Dataset</h3>
      <p>
        <a href="<@s.url value='/dataset/${dataset.key}'/>" title="">${dataset.title}</a>
      </p>

      <#assign institutionCode = action.retrieveTerm('institutionCode')! />
      <#if institutionCode?has_content>
        <h3>Institution code</h3>
        <p>${institutionCode}</p>
      </#if>

      <#assign collectionCode = action.retrieveTerm('collectionCode')! />
      <#if collectionCode?has_content>
          <h3>Collection code</h3>
          <p>${collectionCode}</p>
      </#if>

      <h3>Basis of record</h3>
      <p><@s.text name="enum.basisofrecord.${occ.basisOfRecord!'UNKNOWN'}"/></p>

      <#assign disposition = action.retrieveTerm('disposition')! />
      <#if disposition?has_content>
          <h3>Disposition</h3>
          <p>${disposition}</p>
      </#if>

      <#assign preparations = action.retrieveTerm('preparations')! />
      <#if preparations?has_content>
          <h3>Preparations</h3>
          <p>${preparations}</p>
      </#if>

    </div>

    <div class="right">

      <#assign occurrenceID = action.retrieveTerm('occurrenceID')! />
      <#if occurrenceID?has_content>
          <h3>Occurrence ID</h3>
          <p>${occurrenceID}</p>
      </#if>

      <h3>GBIF ID</h3>
      <p>${id?c}</p>

      <#assign catalogNumber = action.retrieveTerm('catalogNumber')! />
      <#if catalogNumber?has_content>
          <h3>Catalog number</h3>
          <p>${catalogNumber}</p>
      </#if>

      <#assign otherCatalogNumbers = action.retrieveTerm('otherCatalogNumbers')! />
      <#if otherCatalogNumbers?has_content>
          <h3>Other Catalog numbers</h3>
          <p>${otherCatalogNumbers}</p>
      </#if>

      <#list occ.identifiers as i>
        <h3>${i.type}</h3>
        <p>${i.identifier}</p>
      </#list>
    </div>

  <#if verbatim["Record"]??>
    <#-- show additional record-level group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
      <@vList verbatimGroup=verbatim["Record"] title="Additional record-level terms" exclude=["institutionCode", "collectionCode", "rights", "basisOfRecord"] />
  </#if>

  <#if verbatim["Other"]??>
  <#-- show additional DC record-level group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
      <@vList verbatimGroup=verbatim["Other"] title="Other DC record-level terms" exclude=["rights", "accessRights", "bibliographicCitation", "modified", "references", "rightsHolder"] />
  </#if>

</@common.article>

<#assign title>
Identification details <span class='subtitle'>According to <a href="<@s.url value='/dataset/${nubDatasetKey}'/>">GBIF Backbone Taxonomy</a></span>
</#assign>
<@common.article id="taxonomy" title=title>
    <div class="left">
      <#if occ.taxonKey??>
        <h3>Identified as ${occ.rank!"species"}</h3>
        <p><a href="<@s.url value='/species/${occ.taxonKey?c}'/>">${occ.scientificName}</a></p>

        <#if occ.identificationNotes??>
          <h3>Notes</h3>
          <p>${occ.identificationNotes}</p>
        </#if>

        <h3>Taxonomic classification</h3>
        <#assign classification=occ.higherClassificationMap />
        <ul class="taxonomy last-horizontal-line">
          <#list classification?keys as key>
            <li<#if !key_has_next> class="last"</#if>><a href="<@s.url value='/species/${key?c}'/>">${classification.get(key)}</a></li>
          </#list>
        </ul>

      </#if>

      <#if occ.typeStatus??>
          <h3>Type Status</h3>
          <p><@s.text name="enum.typestatus.${occ.typeStatus!'UNKNOWN'}"/></p>
      </#if>

      <#if occ.typifiedName??>
          <h3>Typified Name</h3>
          <p>${occ.typifiedName}</p>
      </#if>

    </div>
    <div class="right">
      <#if occ.dateIdentified??>
        <h3>Identification date </h3>
        <p>${occ.dateIdentified?date?string.medium}</p>
      </#if>

      <#if occ.identifiedBy??>
        <h3>Identified by</h3>
        <p>${occ.identifierName}</p>
      </#if>

      <#assign identifiedBy = action.retrieveTerm('identifiedBy')! />
      <#if identifiedBy?has_content>
          <h3>Identitied By</h3>
          <p>${identifiedBy}</p>
      </#if>

      <#assign individualID = action.retrieveTerm('individualID')! />
      <#if individualID?has_content>
          <h3>Individual ID</h3>
          <p>${individualID}</p>
      </#if>
    </div>

  <#if verbatim["Identification"]??>
    <#-- show additional identification group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <@vList verbatimGroup=verbatim["Identification"] title="Additional identification terms" exclude=["dateIdentified", "typeStatus", "identifiedBy"] />
  </#if>

</@common.article>

<@common.article id="occurrence" title="Occurrence details">
  <div class="left">
    <div class="col">

      <#if occ.eventDate?? || partialGatheringDate?has_content >
        <h3>Event date </h3>
        <#if occ.eventDate??>
            <p>${occ.eventDate?datetime?string.medium}</p>
        <#elseif partialGatheringDate?has_content >
            <p>${partialGatheringDate}</p>
        </#if>
      </#if>

      <#if occ.collectorName??>
        <h3>Collector name</h3>
        <p>${occ.collectorName}</p>
      </#if>

      <#if occ.individualCount??>
          <h3>Individual Count</h3>
          <p>${occ.individualCount?string}</p>
      </#if>

    </div>

  </div>

  <div class="right">

    <#if occ.lifeStage??>
      <h3>Life Stage</h3>
      <p>${occ.lifeStage?string?lower_case?cap_first}</p>
    </#if>

    <#if occ.sex??>
      <h3>Sex</h3>
      <p>${occ.sex?string?lower_case?cap_first}</p>
    </#if>

    <#if occ.establishmentMeans??>
      <h3>Establishment Means</h3>
      <p>${occ.establishmentMeans?string?lower_case?cap_first}</p>
    </#if>
  </div>

  <#if verbatim["Occurrence"]??>
    <#-- show additional occurrence group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <@vList verbatimGroup=verbatim["Occurrence"] title="Additional occurrence terms" exclude=["catalogNumber", "individualCount", "sex", "lifeStage", "establishmentMeans", "individualID", "occurrenceID", "associatedMedia", "disposition" ] />
  </#if>

  <#if verbatim["Event"]??>
    <#-- show additional event group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <@vList verbatimGroup=verbatim["Event"] title="Additional Event terms" exclude=["eventDate", "year", "month", "day"] />
  </#if>

</@common.article>

<#if verbatim["GeologicalContext"]??>
  <#-- show additional geological context group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="geology" title="Geological context">
    <@vList verbatimGroup=verbatim["GeologicalContext"] exclude=[] />
  </@common.article>
</#if>

<#assign associatedMedia = action.retrieveTerm('associatedMedia')! />
<#if associatedMedia?? || (occ.media?size > 0) >
  <@common.article id="media" title="Media">

  <#-- show list of images coming in from DwC associatedMedia. Todo: show actual images -->
  <#if associatedMedia??>
    <h3>Associated Media</h3>
    <p>${associatedMedia}</p>
  </#if>

  <#-- show list of media. Todo: show actual images -->
  <#if (occ.media?size > 0)>
    <#list occ.media as m>
      <h3>Image #${m_index+1}: ${m.title!"No title"}</h3>

        <#if m.image?has_content>
        <p><a href="${m.image}">${m.image}</a></p>
        </#if>

        <#if m.created?has_content>
        <h3>Taken on</h3>
        <p>${m.created?date?string.medium}</p>
        </#if>

        <#if m.creator?has_content>
        <h3>Photographer</h3>
        <p>${m.creator}</p>
        </#if>

        <#if m.publisher?has_content>
        <h3>Publisher</h3>
        <p>${m.publisher}</p>
        </#if>

        <#if m.description?has_content>
        <h3>Description</h3>
        <p>${m.description}</p>
        </#if>

        <#if m.license?has_content>
        <h3>Copyright</h3>
        <p>${m.license}</p>
        </#if>

      <a href="${m.image}" class="read_more">Read more</a>
      </#list>
    </#if>
  </@common.article>
</#if>

<#if (occ.facts?size > 0) >
  <@common.article id="measurementOrFact" title="Measurement or fact">

  <#-- show list of FactOrMeasurement. -->
    <#if (occ.facts?size > 0)>
      <#list occ.facts as fom>
      <h3>Fact or Measurement #${fom_index+1}: ${fom.type!"Type unknown"}</h3>

        <#if fom.value?has_content>
        <p>${fom.value}</p>
        </#if>

        <#if fom.unit?has_content>
        <h3>Unit</h3>
        <p>${fom.unit}</p>
        </#if>

        <#if fom.accuracy?has_content>
        <h3>Accuracy</h3>
        <p>${fom.accuracy}</p>
        </#if>

        <#if fom.method?has_content>
        <h3>Method</h3>
        <p>${fom.method}</p>
        </#if>

        <#if fom.determinedBy?has_content>
        <h3>Determined By</h3>
        <p>${fom.determinedBy}</p>
        </#if>

        <#if fom.determinedDate?has_content>
        <h3>Date Determined</h3>
        <p>${fom.determinedDate}</p>
        </#if>

        <#if fom.remarks?has_content>
        <h3>Remarks</h3>
        <p>${fom.remarks}</p>
        </#if>

      </#list>
    </#if>
  </@common.article>
</#if>

<#if (occ.relations?size > 0) >
  <@common.article id="resourceRelationship" title="Resource Relationship">

  <#-- show list of FactOrMeasurement. -->
    <#if (occ.relations?size > 0)>
      <#list occ.relations as r>
      <h3>Occurrence relation #${r_index+1}: ${r.id!"ID unknown"}</h3>

        <#if r.occurrenceId?has_content>
        <p>${r.occurrenceId}</p>
        </#if>

        <#if r.type?has_content>
        <p>${r.type}</p>
        </#if>

        <#if r.relatedOccurrenceId?has_content>
        <p>${r.relatedOccurrenceId}</p>
        </#if>

        <#if r.accordingTo?has_content>
        <h3>According to</h3>
        <p>${r.accordingTo}</p>
        </#if>

        <#if r.establishedDate?has_content>
        <h3>Date established</h3>
        <p>${r.establishedDate}</p>
        </#if>

        <#if r.remarks?has_content>
        <h3>Remarks</h3>
        <p>${r.remarks}</p>
        </#if>

      </#list>
    </#if>
  </@common.article>
</#if>

<#assign rights = action.retrieveTerm('rights')!"" />
<#assign bibliographicCitation = action.retrieveTerm('bibliographicCitation')!"" />
<#assign accessRights = action.retrieveTerm('accessRights')!"" />
<#assign rightsHolder = action.retrieveTerm('rightsHolder')!"" />
<@citationArticle bibliographicCitation=bibliographicCitation rights=rights accessRights=accessRights rightsHolder=rightsHolder dataset=dataset publisher=publisher />

<@common.notice title="Further information">
  <#if occ.modified??>
  <p>Source record updated ${occ.modified?date?string.medium}</p>
  </#if>
<#if occ.lastCrawled??>
  <p>Last crawled ${occ.lastCrawled?date?string.medium}</p>
</#if>
<#if occ.lastInterpreted??>
  <p>Last interpreted ${occ.lastInterpreted?date?string.medium}</p>
</#if>
<p>There may be more details available about this occurrence in the
  <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>">verbatim version</a> of the record</p>
</@common.notice>

</body>
</html>
