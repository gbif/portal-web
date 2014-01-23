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
    <#if title?has_content>
      <h2>${title}</h2>
    </#if>

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
      <h3>Locality</h3>
        <p class="no_bottom">${locality!}<#if occ.country??>, <a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></#if></p>
        <p class="light_note">${occ.longitude}, ${occ.latitude}</p>

    <#if occ.coordinateAccurracy??>
      <h3>Coordinate Accuracy</h3>
      <p>${occ.coordinateAccurracy?string}</p>
    </#if>

    <#if occ.geodeticDatum??>
      <h3>Geodetic Datum</h3>
      <p>${occ.geodeticDatum}</p>
    </#if>

  <#else>
    <div class="fullwidth">
    <#if occ.continent??>
        <h3>Continent</h3>
        <p>${occ.continent}</p>
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

    <#if locality?has_content>
        <h3>Locality</h3>
        <p>${locality}</p>
    </#if>
  </#if>

    <#if occ.altitude??>
      <h3>Altitude</h3>
      <p>${occ.altitude}m</p>
    </#if>

    <#if occ.altitudeAccurracy??>
      <h3>Altitude Accuracy</h3>
      <p>${occ.altitudeAccurracy?string}</p>
    </#if>

    <#if occ.depth??>
      <h3>Depth</h3>
      <p>${occ.depth}m</p>
    </#if>

    <#if occ.depthAccurracy??>
      <h3>Depth Accuracy</h3>
      <p>${occ.depthAccurracy?string}</p>
    </#if>
   </div>

<#-- show different set of verbatim terms, depending on whether a map is shown or not. Never show verbatim terms that
are expected to be interpreted -->
<#if verbatim["Location"]??>
      <#if showMap>
        <@vList verbatimGroup=verbatim["Location"] title="Additional location terms" exclude=["continent",
    "stateOrProvince", "countryCode", "country", "county", "maximumDepthInMeters", "minimumDepthInMeters",
    "maximumElevationInMeters", "minimumElevationInMeters", "locality", "decimalLatitude", "decimalLongitude",
    "verbatimLatitude", "verbatimLongitude", "verbatimDepth", "verbatimElevation", "verbatimLocality",
    "verbatimCoordinates", "verbatimCoordinateSystem", "coordinatePrecision", "coordinateUncertaintyInMeters",
    "geodeticDatum"] />
      <#else>
        <@vList verbatimGroup=verbatim["Location"] title="Additional location terms" exclude=["continent",
    "stateOrProvince", "countryCode", "country", "county", "maximumDepthInMeters", "minimumDepthInMeters",
    "maximumElevationInMeters", "minimumElevationInMeters", "locality", "verbatimElevation", "verbatimLocality"] />
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

      <#if occ.individualCount??>
          <h3>Individual Count</h3>
          <p>${occ.individualCount?string}</p>
      </#if>

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

    <div class="right">
      <h3>GBIF ID</h3>
      <p>${id?c}</p>

      <#assign catalogNumber = action.retrieveTerm('catalogNumber')! />
      <#if catalogNumber?has_content>
          <h3>Catalog number</h3>
          <p>${catalogNumber}</p>
      </#if>

      <#list occ.identifiers as i>
        <h3>${i.type}</h3>
        <p>${i.identifier}</p>
      </#list>
    </div>

  <#if verbatim["Record"]??>
    <#-- show additional record-level group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <#if verbatim?has_content>
      <@vList verbatimGroup=verbatim["Record"] title="Additional record-level terms" exclude=["institutionCode", "collectionCode", "rights"] />
    </#if>
  </#if>

  <#if verbatim["Occurrence"]??>
    <#-- show additional occurrence group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <#if verbatim?has_content>
      <@vList verbatimGroup=verbatim["Occurrence"] title="Additional occurrence terms" exclude=["catalogNumber", "individualCount", "sex", "lifeStage", "establishmentMeans" ] />
    </#if>
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
      <#if occ.identificationDate??>
        <h3>Identification date </h3>
        <p>${occ.identificationDate?date?string.medium}</p>
      </#if>

      <#if occ.identifierName??>
        <h3>Identified by</h3>
        <p>${occ.identifierName}</p>
      </#if>
    </div>

  <#if verbatim["Identification"]??>
  <#-- show additional identification group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <#if verbatim?has_content>
      <@vList verbatimGroup=verbatim["Identification"] title="Additional identification terms" exclude=["dateIdentified", "typeStatus"] />
    </#if>
  </#if>

  <#if verbatim["Taxon"]??>
  <#-- show additional taxon group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <#if verbatim?has_content>
        <@vList verbatimGroup=verbatim["Taxon"] title="Additional taxon terms" exclude=["kingdom", "phylum", "class", "order", "family", "genus", "subgenus", "specificEpithet", "scientificName", "higherClassification", "infraspecificEpithet", "verbatimTaxonRank", "taxonRank"] />
      </#if>
  </#if>
</@common.article>

<@common.article id="collection" title="Collection details">
  <div class="left">
    <div class="col">
      <h3>Basis of record</h3>
      <p><@s.text name="enum.basisofrecord.${occ.basisOfRecord!'UNKNOWN'}"/></p>

      <#if occ.eventDate?? || partialGatheringDate?has_content >
        <h3>Gathering date </h3>
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

    </div>
  </div>

  <#if verbatim["Event"]??>
  <#-- show additional event group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
    <#if verbatim?has_content>
      <@vList verbatimGroup=verbatim["Event"] title="Additional Event terms" exclude=["eventDate"] />
    </#if>
  </#if>

</@common.article>

<#if verbatim["GeologicalContext"]??>
  <#-- show additional geological context group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="geology" title="Geological context">
    <#if verbatim?has_content>
      <@vList verbatimGroup=verbatim["GeologicalContext"] exclude=[] />
    </#if>
  </@common.article>
</#if>

<#if verbatim["ResourceRelationship"]??>
<#-- show additional resource relationship group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
<@common.article id="resourceRelationship" title="Resource Relationship">
  <#if verbatim?has_content>
        <@vList verbatimGroup=verbatim["ResourceRelationship"] exclude=[] />
      </#if>
</@common.article>
</#if>

<#if verbatim["MeasurementOrFact"]??>
<#-- show additional measurement or fact group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="measurementOrFact" title="Measurement or fact">
    <#if verbatim?has_content>
      <@vList verbatimGroup=verbatim["MeasurementOrFact"] exclude=[] />
    </#if>
  </@common.article>
</#if>

<#assign rts = action.retrieveTerm('rights')! />
<#if rts??>
  <@common.citationArticle rights=rts!"" dataset=dataset publisher=publisher />
<#else>
  <@common.citationArticle rights=dataset.rights!"" dataset=dataset publisher=publisher />
</#if>


<@common.notice title="Further information">
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
