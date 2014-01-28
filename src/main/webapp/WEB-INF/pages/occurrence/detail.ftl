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
<#assign county = action.retrieveTerm('county')! />
<#assign municipality = action.retrieveTerm('municipality')! />
<#assign island = action.retrieveTerm('island')! />
<#assign islandGroup = action.retrieveTerm('islandGroup')! />

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
    <div class="scrollable330">

      <h3>Locality</h3>
      <p class="no_bottom">${locality!}<#if occ.country??>, <a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></#if></p>
      <p class="light_note">${occ.longitude}, ${occ.latitude}</p>

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

      <#if county??>
        <h3>County</h3>
        <p>${county}</p>
      </#if>

      <#if municipality??>
        <h3>Municipality</h3>
        <p>${municipality}</p>
      </#if>

      <#if occ.waterBody??>
        <h3>Water Body</h3>
        <p>${occ.waterBody}</p>
      </#if>

      <#if island??>
        <h3>Island</h3>
        <p>${island}</p>
      </#if>

      <#if islandGroup??>
        <h3>Island Group</h3>
        <p>${islandGroup}</p>
      </#if>

      <#if occ.coordinateAccuracy??>
        <h3>Coordinate Accuracy</h3>
        <p>${occ.coordinateAccuracy?string}</p>
      </#if>

      <#if occ.geodeticDatum??>
        <h3>Geodetic Datum</h3>
        <p>${occ.geodeticDatum}</p>
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

  <#else>
    <div class="fullwidth">

    <#if locality?has_content>
        <h3>Locality</h3>
        <p>${locality}</p>
    </#if>

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

    <#if county??>
        <h3>County</h3>
        <p>${county}</p>
    </#if>

    <#if municipality??>
        <h3>Municipality</h3>
        <p>${municipality}</p>
    </#if>

    <#if occ.waterBody??>
        <h3>Water Body</h3>
        <p>${occ.waterBody}</p>
    </#if>

    <#if island??>
        <h3>Island</h3>
        <p>${island}</p>
    </#if>

    <#if islandGroup??>
        <h3>Island Group</h3>
        <p>${islandGroup}</p>
    </#if>

    <#if occ.altitude??>
        <h3>Altitude</h3>
        <p>${occ.altitude}m<#if occ.altitudeAccuracy??> ± ${occ.altitudeAccuracy?string}</#if></p>
    </#if>

    <#if occ.depth??>
        <h3>Depth</h3>
        <p>${occ.depth}m<#if occ.depthAccuracy??> ± ${occ.depthAccuracy?string}</#if></p>
    </#if>

  </#if>

   </div>
<div class="fullwidth fullwidth_under_map">

    <div class="left">
      <#assign footprintSRS = action.retrieveTerm('footprintSRS')! />
      <#if footprintSRS?has_content>
          <h3>Footprint SRS</h3>
          <p>${footprintSRS}</p>
      </#if>
      <#assign footprintWKT = action.retrieveTerm('footprintWKT')! />
      <#if footprintWKT?has_content>
          <h3>Footprint WKT</h3>
          <p>${footprintWKT}</p>
      </#if>
      <#assign footprintSpatialFit = action.retrieveTerm('footprintSpatialFit')! />
      <#if footprintSpatialFit?has_content>
          <h3>Footprint Spatial Fit</h3>
          <p>${footprintSpatialFit}</p>
      </#if>
      <#assign georeferenceProtocol = action.retrieveTerm('georeferenceProtocol')! />
      <#if georeferenceProtocol?has_content>
          <h3>Georeference Protocol</h3>
          <p>${georeferenceProtocol}</p>
      </#if>
      <#assign georeferenceSources = action.retrieveTerm('georeferenceSources')! />
      <#if georeferenceSources?has_content>
          <h3>Georeference Sources</h3>
          <p>${georeferenceSources}</p>
      </#if>
      <#assign georeferenceVerificationStatus = action.retrieveTerm('georeferenceVerificationStatus')! />
      <#if georeferenceVerificationStatus?has_content>
          <h3>Georeference Verification Status</h3>
          <p>${georeferenceVerificationStatus}</p>
      </#if>
      <#assign georeferencedBy = action.retrieveTerm('georeferencedBy')! />
      <#if georeferencedBy?has_content>
          <h3>Georeferenced By</h3>
          <p>${georeferencedBy}</p>
      </#if>
      <#assign locationAccordingTo = action.retrieveTerm('locationAccordingTo')! />
      <#if locationAccordingTo?has_content>
          <h3>Location According To</h3>
          <p>${locationAccordingTo}</p>
      </#if>
      <#assign locationRemarks = action.retrieveTerm('locationRemarks')! />
      <#if locationRemarks?has_content>
          <h3>Location Remarks</h3>
          <p>${locationRemarks}</p>
      </#if>
      <#assign maximumDistanceAboveSurfaceInMeters = action.retrieveTerm('maximumDistanceAboveSurfaceInMeters')! />
      <#if maximumDistanceAboveSurfaceInMeters?has_content>
          <h3>Maximum Distance AboveSurface In Meters</h3>
          <p>${maximumDistanceAboveSurfaceInMeters}</p>
      </#if>
      <#assign minimumDistanceAboveSurfaceInMeters = action.retrieveTerm('minimumDistanceAboveSurfaceInMeters')! />
      <#if minimumDistanceAboveSurfaceInMeters?has_content>
          <h3>Minimum Distance AboveSurface In Meters</h3>
          <p>${minimumDistanceAboveSurfaceInMeters}</p>
      </#if>
      <#assign pointRadiusSpatialFit = action.retrieveTerm('pointRadiusSpatialFit')! />
      <#if pointRadiusSpatialFit?has_content>
          <h3>Point Radius Spatial Fit</h3>
          <p>${pointRadiusSpatialFit}</p>
      </#if>
    </div>

    <div class="right right_under_map">
      <#assign georeferencedDate = action.retrieveTerm('georeferencedDate')! />
      <#if georeferencedDate?has_content>
          <h3>Georeferenced Date</h3>
          <p>${georeferencedDate}</p>
      </#if>
      <#assign higherGeographyID = action.retrieveTerm('higherGeographyID')! />
      <#if higherGeographyID?has_content>
          <h3>Higher Geography ID</h3>
          <p>${higherGeographyID}</p>
      </#if>
      <#assign locationID = action.retrieveTerm('locationID')! />
      <#if locationID?has_content>
          <h3>Location ID</h3>
          <p>${locationID}</p>
      </#if>
    </div>
</div>

</@common.article>

<@common.article id="source" title="Source details">
    <div class="left">
      <h3>Data publisher</h3>
      <p>
        <a href="<@s.url value='/publisher/${publisher.key}'/>" title="">${publisher.title}</a>
      </p>

      <#-- institution code and institution ID on same line -->
      <#assign institutionCode = action.retrieveTerm('institutionCode')! />
      <#assign institutionID = action.retrieveTerm('institutionID')! />
      <#if institutionCode?has_content && institutionID?has_content>
          <h3>Institution code / ID</h3>
          <p>${institutionCode} / ${institutionID}</p>
      <#elseif institutionCode?has_content>
          <h3>Institution code</h3>
          <p>${institutionCode}</p>
      <#elseif institutionID?has_content>
          <h3>Institution ID</h3>
          <p>${institutionID}</p>
      </#if>

      <h3>Dataset</h3>
      <p>
        <a href="<@s.url value='/dataset/${dataset.key}'/>" title="">${dataset.title}</a>
      </p>

      <#-- dataset and dataset ID on same line -->
      <#assign datasetID = action.retrieveTerm('datasetID')! />
      <#assign datasetName = action.retrieveTerm('datasetName')! />
      <#if datasetName?has_content && datasetID?has_content>
          <h3>Dataset Name / ID</h3>
          <p>${datasetName} / ${datasetID}</p>
      <#elseif datasetName?has_content>
          <h3>Dataset Name</h3>
          <p>${datasetName}</a></p>
      <#elseif datasetID?has_content>
          <h3>Dataset ID</h3>
          <p>${datasetID}</p>
      </#if>

      <#-- collection code and institution ID on same line -->
      <#assign collectionCode = action.retrieveTerm('collectionCode')! />
      <#assign collectionID = action.retrieveTerm('collectionID')! />
      <#if collectionCode?has_content && collectionID?has_content>
        <h3>Collection code / ID</h3>
        <p>${collectionCode} / ${collectionID}</p>
      <#elseif collectionCode?has_content>
        <h3>Collection code</h3>
        <p>${collectionCode}</p>
      <#elseif collectionID?has_content>
          <h3>Collection ID</h3>
          <p>${collectionID}</p>
      </#if>

    <#-- basis of record and type on same line -->
      <#assign type =  action.retrieveTerm('type')! />
      <#if occ.basisOfRecord?has_content && type?has_content>
          <h3>Basis of record / type</h3>
          <p><@s.text name="enum.basisofrecord.${occ.basisOfRecord!'UNKNOWN'}"/> / ${type}</p>
      <#elseif occ.basisOfRecord?has_content>
          <h3>Basis of record</h3>
          <p><@s.text name="enum.basisofrecord.${occ.basisOfRecord!'UNKNOWN'}"/></p>
      <#elseif type?has_content>
          <h3>Type</h3>
          <p>${type}</p>
      </#if>

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

      <#assign dataGeneralizations = action.retrieveTerm('dataGeneralizations')! />
      <#if dataGeneralizations?has_content>
          <h3>Data Generalizations</h3>
          <p>${dataGeneralizations}</p>
      </#if>

      <#assign informationWithheld = action.retrieveTerm('informationWithheld')! />
      <#if informationWithheld?has_content>
          <h3>Information Withheld</h3>
          <p>${informationWithheld}</p>
      </#if>

      <#assign dynamicProperties = action.retrieveTerm('dynamicProperties')! />
      <#if dynamicProperties?has_content>
          <h3>Dynamic Properties</h3>
          <p>${dynamicProperties}</p>
      </#if>

      <#assign ownerInstitutionCode = action.retrieveTerm('ownerInstitutionCode')! />
      <#if ownerInstitutionCode?has_content>
          <h3>Owner Institution Code</h3>
          <p>${ownerInstitutionCode}</p>
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

      <#assign language = action.retrieveTerm('language')! />
      <#if language?has_content>
          <h3>Language</h3>
          <p>${language}</p>
      </#if>
    </div>

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

      <#assign identificationRemarks = action.retrieveTerm('identificationRemarks')! />
      <#if identificationRemarks?has_content>
          <h3>Identification Remarks</h3>
          <p>${identificationRemarks}</p>
      </#if>

      <#assign identificationReferences = action.retrieveTerm('identificationReferences')! />
      <#if identificationReferences?has_content>
          <h3>Identification References</h3>
          <p>${identificationReferences}</p>
      </#if>

      <#assign identificationQualifier = action.retrieveTerm('identificationQualifier')! />
      <#if identificationQualifier?has_content>
          <h3>Identification Qualifier</h3>
          <p>${identificationQualifier}</p>
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

      <#assign identificationID = action.retrieveTerm('identificationID')! />
      <#if identificationID?has_content>
          <h3>Identification ID</h3>
          <p>${identificationID}</p>
      </#if>

      <#assign identificationVerificationStatus = action.retrieveTerm('identificationVerificationStatus')! />
      <#if identificationVerificationStatus?has_content>
          <h3>Identification Verification Status</h3>
          <p>${identificationVerificationStatus}</p>
      </#if>
    </div>

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

      <#assign associatedOccurrences = action.retrieveTerm('associatedOccurrences')! />
      <#if associatedOccurrences?has_content>
          <h3>Associated Occurrences</h3>
          <p>${associatedOccurrences}</p>
      </#if>

      <#assign associatedSequences = action.retrieveTerm('associatedSequences')! />
      <#if associatedSequences?has_content>
          <h3>Associated Sequences</h3>
          <p>${associatedSequences}</p>
      </#if>

      <#assign associatedReferences = action.retrieveTerm('associatedReferences')! />
      <#if associatedReferences?has_content>
          <h3>Associated References</h3>
          <p>${associatedReferences}</p>
      </#if>

      <#assign associatedTaxa = action.retrieveTerm('associatedTaxa')! />
      <#if associatedTaxa?has_content>
          <h3>Associated Taxa</h3>
          <p>${associatedTaxa}</p>
      </#if>

      <#assign occurrenceStatus = action.retrieveTerm('occurrenceStatus')! />
      <#if occurrenceStatus?has_content>
          <h3>Occurrence Status</h3>
          <p>${occurrenceStatus}</p>
      </#if>

      <#assign behavior = action.retrieveTerm('behavior')! />
      <#if behavior?has_content>
          <h3>Behavior</h3>
          <p>${behavior}</p>
      </#if>

      <#assign occurrenceRemarks = action.retrieveTerm('occurrenceRemarks')! />
      <#if occurrenceRemarks?has_content>
          <h3>Occurrence Remarks</h3>
          <p>${occurrenceRemarks}</p>
      </#if>

      <#assign previousIdentifications = action.retrieveTerm('previousIdentifications')! />
      <#if previousIdentifications?has_content>
          <h3>Previous Identifications</h3>
          <p>${previousIdentifications}</p>
      </#if>

      <#assign eventRemarks = action.retrieveTerm('eventRemarks')! />
      <#if eventRemarks?has_content>
          <h3>Event Remarks</h3>
          <p>${eventRemarks}</p>
      </#if>

      <#assign fieldNotes = action.retrieveTerm('fieldNotes')! />
      <#if fieldNotes?has_content>
          <h3>Field Notes</h3>
          <p>${fieldNotes}</p>
      </#if>

      <#assign habitat = action.retrieveTerm('habitat')! />
      <#if habitat?has_content>
          <h3>Habitat</h3>
          <p>${habitat}</p>
      </#if>

      <#assign samplingProtocol = action.retrieveTerm('samplingProtocol')! />
      <#if samplingProtocol?has_content>
          <h3>Sampling Protocol</h3>
          <p>${samplingProtocol}</p>
      </#if>

      <#assign samplingEffort = action.retrieveTerm('samplingEffort')! />
      <#if samplingEffort?has_content>
          <h3>Sampling Effort</h3>
          <p>${samplingEffort}</p>
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

    <#assign occurrenceStatus = action.retrieveTerm('occurrenceStatus')! />
    <#if occurrenceStatus?has_content>
        <h3>Occurrence Status</h3>
        <p>${occurrenceStatus}</p>
    </#if>

    <#assign recordedBy = action.retrieveTerm('recordedBy')! />
    <#if recordedBy?has_content>
        <h3>Recorded By</h3>
        <p>${recordedBy}</p>
    </#if>

    <#assign recordNumber = action.retrieveTerm('recordNumber')! />
    <#if recordNumber?has_content>
        <h3>Record Number</h3>
        <p>${recordNumber}</p>
    </#if>

    <#assign reproductiveCondition = action.retrieveTerm('reproductiveCondition')! />
    <#if reproductiveCondition?has_content>
        <h3>Reproductive Condition</h3>
        <p>${reproductiveCondition}</p>
    </#if>

    <#assign eventID = action.retrieveTerm('eventID')! />
    <#if eventID?has_content>
        <h3>Event ID</h3>
        <p>${eventID}</p>
    </#if>

    <#assign fieldNumber = action.retrieveTerm('fieldNumber')! />
    <#if fieldNumber?has_content>
        <h3>Field Number</h3>
        <p>${fieldNumber}</p>
    </#if>

    <#assign startDayOfYear = action.retrieveTerm('startDayOfYear')! />
    <#if startDayOfYear?has_content>
        <h3>Start Day Of Year</h3>
        <p>${startDayOfYear}</p>
    </#if>

    <#assign endDayOfYear = action.retrieveTerm('endDayOfYear')! />
    <#if endDayOfYear?has_content>
        <h3>End Day Of Year</h3>
        <p>${endDayOfYear}</p>
    </#if>

    <#assign eventTime = action.retrieveTerm('eventTime')! />
    <#if eventTime?has_content>
        <h3>Event Time</h3>
        <p>${eventTime}</p>
    </#if>

    <#assign verbatimEventDate = action.retrieveTerm('verbatimEventDate')! />
    <#if verbatimEventDate?has_content>
        <h3>Verbatim Event Date</h3>
        <p>${verbatimEventDate}</p>
    </#if>

  </div>

</@common.article>

<#if verbatim["GeologicalContext"]??>
  <#-- show additional geological context group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="geology" title="Geological context">
    <div class="left">

      <#assign bed = action.retrieveTerm('bed')! />
      <#if bed?has_content>
          <h3>Bed</h3>
          <p>${bed}</p>
      </#if>

      <#assign formation = action.retrieveTerm('formation')! />
      <#if formation?has_content>
          <h3>Formation</h3>
          <p>${formation}</p>
      </#if>

      <#assign group = action.retrieveTerm('group')! />
      <#if group?has_content>
          <h3>Group</h3>
          <p>${group}</p>
      </#if>

      <#assign member = action.retrieveTerm('member')! />
      <#if member?has_content>
          <h3>Member</h3>
          <p>${member}</p>
      </#if>

      <#assign earliestEonOrLowestEonothem = action.retrieveTerm('earliestEonOrLowestEonothem')! />
      <#if earliestEonOrLowestEonothem?has_content>
          <h3>Earliest Eon Or Lowest Eonothem</h3>
          <p>${earliestEonOrLowestEonothem}</p>
      </#if>

      <#assign latestEonOrHighestEonothem = action.retrieveTerm('latestEonOrHighestEonothem')! />
      <#if latestEonOrHighestEonothem?has_content>
          <h3>Latest Eon Or Highest Eonothem</h3>
          <p>${latestEonOrHighestEonothem}</p>
      </#if>

      <#assign earliestEraOrLowestErathem = action.retrieveTerm('earliestEraOrLowestErathem')! />
      <#if earliestEraOrLowestErathem?has_content>
          <h3>Earliest Era Or Lowest Erathem</h3>
          <p>${earliestEraOrLowestErathem}</p>
      </#if>

      <#assign latestEraOrHighestErathem = action.retrieveTerm('latestEraOrHighestErathem')! />
      <#if latestEraOrHighestErathem?has_content>
          <h3>Latest Era Or Highest Erathem</h3>
          <p>${latestEraOrHighestErathem}</p>
      </#if>

      <#assign earliestAgeOrLowestStage = action.retrieveTerm('earliestAgeOrLowestStage')! />
      <#if earliestAgeOrLowestStage?has_content>
          <h3>Earliest Age Or Lowest Stage</h3>
          <p>${earliestAgeOrLowestStage}</p>
      </#if>

      <#assign latestAgeOrHighestStage = action.retrieveTerm('latestAgeOrHighestStage')! />
      <#if latestAgeOrHighestStage?has_content>
          <h3>Latest Age Or Highest Stage</h3>
          <p>${latestAgeOrHighestStage}</p>
      </#if>

      <#assign earliestEpochOrLowestSeries = action.retrieveTerm('earliestEpochOrLowestSeries')! />
      <#if earliestEpochOrLowestSeries?has_content>
          <h3>Earliest Epoch Or Lowest Series</h3>
          <p>${earliestEpochOrLowestSeries}</p>
      </#if>

      <#assign latestEpochOrHighestSeries = action.retrieveTerm('latestEpochOrHighestSeries')! />
      <#if latestEpochOrHighestSeries?has_content>
          <h3>Latest Epoch Or Highest Series</h3>
          <p>${latestEpochOrHighestSeries}</p>
      </#if>

      <#assign earliestPeriodOrLowestSystem = action.retrieveTerm('earliestPeriodOrLowestSystem')! />
      <#if earliestPeriodOrLowestSystem?has_content>
          <h3>Earliest Period Or Lowest System</h3>
          <p>${earliestPeriodOrLowestSystem}</p>
      </#if>

      <#assign latestPeriodOrHighestSystem = action.retrieveTerm('latestPeriodOrHighestSystem')! />
      <#if latestPeriodOrHighestSystem?has_content>
          <h3>Latest Period Or Highest System</h3>
          <p>${latestPeriodOrHighestSystem}</p>
      </#if>

      <#assign lowestBiostratigraphicZone = action.retrieveTerm('lowestBiostratigraphicZone')! />
      <#if lowestBiostratigraphicZone?has_content>
          <h3>Lowest Biostratigraphic Zone</h3>
          <p>${lowestBiostratigraphicZone}</p>
      </#if>

      <#assign highestBiostratigraphicZone = action.retrieveTerm('highestBiostratigraphicZone')! />
      <#if highestBiostratigraphicZone?has_content>
          <h3>Highest Biostratigraphic Zone</h3>
          <p>${highestBiostratigraphicZone}</p>
      </#if>

    </div>

    <div class="right">

      <#assign geologicalContextID = action.retrieveTerm('geologicalContextID')! />
      <#if geologicalContextID?has_content>
          <h3>Geological Context ID</h3>
          <p>${geologicalContextID}</p>
      </#if>

      <#assign lithostratigraphicTerms = action.retrieveTerm('lithostratigraphicTerms')! />
      <#if lithostratigraphicTerms?has_content>
          <h3>Lithostratigraphic Terms</h3>
          <p>${lithostratigraphicTerms}</p>
      </#if>

    </div>

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
