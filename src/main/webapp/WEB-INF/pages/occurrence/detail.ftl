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

<#macro geoClassification header geographicClassification>
  <#if (geographicClassification?size >0) >
    <h3>${header}</h3>
    <p>
      <#list geographicClassification as c>
        <#if c?has_content>${c}<#if c_has_next>&nbsp;&gt;&nbsp;</#if></#if>
      </#list>
    </p>
  </#if>
</#macro>

<#macro islandClassification header island islandGroup>
  <#if island?has_content || islandGroup?has_content>
    <h3>${header}</h3>
    <p>
      <#if island?has_content>
        ${island}<#if islandGroup?has_content>&nbsp;&gt;&nbsp;${islandGroup}</#if>
      <#elseif islandGroup?has_content>
        ${islandGroup}
      </#if>
    </p>
  </#if>
</#macro>

<#macro kv header value="" term="">
  <#assign retrieved = "" />
  <#if term?has_content>
    <#assign retrieved = action.retrieveTerm(term)!"" />
  </#if>
  <#if retrieved?has_content || value?has_content>
    <h3>${header}</h3>
    <#-- retrieve value from term, otherwise use incoming value -->
    <p><#if retrieved?has_content>${retrieved}<#else>${value}</#if></p>
  </#if>
</#macro>

<#macro footprint header wkt srs fit>
  <#if wkt?has_content || srs?has_content || fit?has_content>
  <h3>${header}</h3>
    <#if wkt?has_content>
    <p>
    ${wkt}<br/>
      <#if srs?has_content || fit?has_content>
          [<#if srs?has_content>SRS=${srs}</#if> <#if fit?has_content>Spatial Fit=${fit}</#if>]
      </#if>
    </p>
    </#if>
  </#if>
</#macro>

<#assign locality = action.retrieveTerm('locality')! />
<#assign island = action.retrieveTerm('island')! />
<#assign islandGroup = action.retrieveTerm('islandGroup')! />

<@common.article id="location" title=title titleRight=titleRight class="occurrenceMap">
  <#if showMap>
    <div id="map" class="map">
      <iframe id="mapframe" name="mapframe" src="${cfg.tileServerBaseUrl!}/point.html?&style=grey-blue&point=${occ.latitude?c},${occ.longitude?c}&lat=${occ.latitude?c}&lng=${occ.longitude?c}&zoom=8" height="100%" width="100%" frameborder="0"/></iframe>
    </div>

    <div class="right">
     <div class="scrollable330">

      <h3>Locality</h3>
      <p class="no_bottom">${locality!}<#if occ.country??><#if locality?has_content>, </#if><a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></#if></p>
      <p class="light_note">${occ.longitude}, ${occ.latitude} <#if occ.coordinateAccuracy??> ± ${occ.coordinateAccuracy?string}</#if></p>

      <#if occ.waterBody??>
        <h3>Water Body</h3>
        <p>${occ.waterBody}</p>
      </#if>

      <#if occ.altitude??>
        <h3>Altitude</h3>
        <p>${occ.altitude}m<#if occ.altitudeAccuracy??> ± ${occ.altitudeAccuracy?string}</#if></p>
      </#if>

      <#if occ.depth??>
        <h3>Depth</h3>
        <p>${occ.depth}m<#if occ.depthAccuracy??> ± ${occ.depthAccuracy?string}</#if></p>
      </#if>

      <#-- TODO: maximum distance above surface with accuracy, see http://dev.gbif.org/issues/browse/POR-1746 -->

      </div>
    </div>
    <div class="fullwidth fullwidth_under_map">
      <div class="left">
        <@geoClassification header="Geographic Classification" geographicClassification=geographicClassification/>
        <@islandClassification header="Islands" island=island islandGroup=islandGroup />

        <#assign habitat = action.retrieveTerm('habitat')! />
        <#if habitat?has_content>
            <h3>Habitat</h3>
            <p>${habitat}</p>
        </#if>

        <#assign footprintWKT = action.retrieveTerm('footprintWKT')! />
        <#assign footprintSRS = action.retrieveTerm('footprintSRS')! />
        <#assign footprintSpatialFit = action.retrieveTerm('footprintSpatialFit')! />
        <@footprint header="Footprint" wkt=footprintWKT srs=footprintSRS fit=footprintSpatialFit />

        <#assign georeferencedDate = action.retrieveTerm('georeferencedDate')! />
        <#assign georeferencedBy = action.retrieveTerm('georeferencedBy')! />
        <#if georeferencedDate?has_content && georeferencedBy?has_content>
          <@kv header="Georeferenced" value=georeferencedDate  + " by " + georeferencedBy />
        <#elseif georeferencedDate?has_content>
          <@kv header="Georeferenced" value=georeferencedDate />
        <#elseif georeferencedBy?has_content>
          <@kv header="Georeferenced" value=georeferencedBy />
       </#if>

       <@kv header="Georeference Protocol" term='georeferenceProtocol' />
       <@kv header="Georeference Sources" term='georeferenceSources' />
       <@kv header="Georeference Verification Status" term='georeferenceVerificationStatus' />
       <@kv header="Remarks" term='locationRemarks' />
     </div>

     <div class="right right_under_map">
       <@kv header="Higher Geography ID" term='higherGeographyID' />
       <@kv header="Location ID" term='locationID' />
       <@kv header="Location According To" term='locationAccordingTo' />
     </div>
  </div>

  <#else>
    <div class="fullwidth fullwidth_under_map">

    <div class="left">
      <@kv header="Locality" term='locality' />

      <#if occ.altitude??>
          <h3>Altitude</h3>
          <p>${occ.altitude}m<#if occ.altitudeAccuracy??> ± ${occ.altitudeAccuracy?string}</#if></p>
      </#if>

      <#if occ.depth??>
          <h3>Depth</h3>
          <p>${occ.depth}m<#if occ.depthAccuracy??> ± ${occ.depthAccuracy?string}</#if></p>
      </#if>

      <#if occ.waterBody??>
          <h3>Water Body</h3>
          <p>${occ.waterBody}</p>
      </#if>

      <@geoClassification header="Geographic Classification" geographicClassification=geographicClassification/>
      <@islandClassification header="Islands" island=island islandGroup=islandGroup />

      <#assign habitat = action.retrieveTerm('habitat')! />
      <#if habitat?has_content>
          <h3>Habitat</h3>
          <p>${habitat}</p>
      </#if>

      <#assign footprintWKT = action.retrieveTerm('footprintWKT')! />
      <#assign footprintSRS = action.retrieveTerm('footprintSRS')! />
      <#assign footprintSpatialFit = action.retrieveTerm('footprintSpatialFit')! />
      <@footprint header="Footprint" wkt=footprintWKT srs=footprintSRS fit=footprintSpatialFit />

      <#assign georeferencedDate = action.retrieveTerm('georeferencedDate')! />
      <#assign georeferencedBy = action.retrieveTerm('georeferencedBy')! />
      <#if georeferencedDate?has_content && georeferencedBy?has_content>
        <@kv header="Georeferenced" value=georeferencedDate  + " by " + georeferencedBy />
      <#elseif georeferencedDate?has_content>
        <@kv header="Georeferenced" value=georeferencedDate />
      <#elseif georeferencedBy?has_content>
        <@kv header="Georeferenced" value="By " + georeferencedBy />
      </#if>

      <@kv header="Georeference Protocol" term='georeferenceProtocol' />
      <@kv header="Georeference Sources" term='georeferenceSources' />
      <@kv header="Georeference Verification Status" term='georeferenceVerificationStatus' />
      <@kv header="Remarks" term='locationRemarks' />
    </div>
    <div class="right right_under_map">
      <@kv header="Higher Geography ID" term='higherGeographyID' />
       <@kv header="Location ID" term='locationID' />
       <@kv header="Location According To" term='locationAccordingTo' />
    </div>
  </div>
  </#if>

</@common.article>

<#assign title>
Identification details <span class='subtitle'>According to <a href="<@s.url value='/dataset/${nubDatasetKey}'/>">GBIF Backbone Taxonomy</a></span>
</#assign>
<@common.article id="taxonomy" title=title>
    <div class="left">
      <#if occ.taxonKey??>
        <#assign identificationQualifier = action.retrieveTerm('identificationQualifier')! />
        <h3>Identified as ${occ.rank!"species"}</h3>
        <p><a href="<@s.url value='/species/${occ.taxonKey?c}'/>">${occ.scientificName}</a><#if identificationQualifier?has_content>&nbsp;[${identificationQualifier}]</#if></p>

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
          <p><@s.text name="enum.typestatus.${occ.typeStatus!'UNKNOWN'}"/><#if occ.typifiedName??>&nbsp;of&nbsp;${occ.typifiedName}</#if></p>
      </#if>

      <#assign previousIdentifications = action.retrieveTerm('previousIdentifications')! />
      <#if previousIdentifications?has_content>
          <h3>Previous Identifications</h3>
          <p>${previousIdentifications}</p>
      </#if>

      <#assign identificationReferences = action.retrieveTerm('identificationReferences')! />
      <#if identificationReferences?has_content>
          <h3>References</h3>
          <p>${identificationReferences}</p>
      </#if>

      <#assign identificationRemarks = action.retrieveTerm('identificationRemarks')! />
      <#if identificationRemarks?has_content>
          <h3>Remarks</h3>
          <p>${identificationRemarks}</p>
      </#if>

    </div>
    <div class="right">

      <#assign identifiedBy = action.retrieveTerm('identifiedBy')! />
      <#if occ.dateIdentified?? && identifiedBy?has_content>
        <@kv header="Identified" value=occ.dateIdentified?date?string.medium!  + " by " + identifiedBy />
      <#elseif occ.dateIdentified??>
        <@kv header="Identified" value=occ.dateIdentified?date?string.medium! />
      <#elseif identifiedBy?has_content>
        <@kv header="Identified" value="By " + identifiedBy />
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
          <h3>Verification Status</h3>
          <p>${identificationVerificationStatus}</p>
      </#if>
    </div>

</@common.article>

<@common.article id="occurrence" title="Occurrence details">
  <div class="left">
    <div class="col">

      <#-- Show event date, partial event date, or verbatim event date in that order of priority + the recorder -->
      <#assign recordedBy = action.retrieveTerm('recordedBy')! />
      <#assign verbatimEventDate = action.retrieveTerm('verbatimEventDate')! />
      <#if occ.eventDate?? || partialGatheringDate?has_content || recordedBy?has_content || verbatimEventDate?has_content >
        <h3>Recorded</h3>
        <#if occ.eventDate??>
          <p>${occ.eventDate?datetime?string.medium}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
        <#elseif partialGatheringDate?has_content >
          <p>${partialGatheringDate}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
        <#elseif verbatimEventDate?has_content >
            <p>${verbatimEventDate}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
        <#else>
          <p>By&nbsp;${recordedBy}</p>
        </#if>
      </#if>

      <#if occ.collectorName??>
        <h3>Collector name</h3>
        <p>${occ.collectorName}</p>
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

        <#assign fieldNotes = action.retrieveTerm('fieldNotes')! />
        <#if fieldNotes?has_content>
            <h3>Field Notes</h3>
            <p>${fieldNotes}</p>
        </#if>

      <#-- Combine occurrence remarks and event remarks under the same heading Remarks -->
      <#assign occurrenceRemarks = action.retrieveTerm('occurrenceRemarks')! />
      <#assign eventRemarks = action.retrieveTerm('eventRemarks')! />
      <#if occurrenceRemarks?has_content || eventRemarks?has_content>
        <h3>Remarks</h3>
        <#if occurrenceRemarks?has_content && eventRemarks?has_content>
          <p>${occurrenceRemarks}</p>
          <p>${eventRemarks}</p>
        <#elseif occurrenceRemarks?has_content>
          <p>${occurrenceRemarks}</p>
        <#else>
          <p>${eventRemarks}</p>
        </#if>
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

    <#assign reproductiveCondition = action.retrieveTerm('reproductiveCondition')! />
    <#if reproductiveCondition?has_content>
        <h3>Reproductive Condition</h3>
        <p>${reproductiveCondition}</p>
    </#if>

    <#if occ.individualCount??>
        <h3>Individual Count</h3>
        <p>${occ.individualCount?string}</p>
    </#if>

    <#assign behavior = action.retrieveTerm('behavior')! />
    <#if behavior?has_content>
        <h3>Behavior</h3>
        <p>${behavior}</p>
    </#if>

    <#assign occurrenceStatus = action.retrieveTerm('occurrenceStatus')! />
    <#if occurrenceStatus?has_content>
        <h3>Occurrence Status</h3>
        <p>${occurrenceStatus}</p>
    </#if>

    <#assign recordNumber = action.retrieveTerm('recordNumber')! />
    <#if recordNumber?has_content>
        <h3>Record Number</h3>
        <p>${recordNumber}</p>
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

  <#assign ownerInstitutionCode = action.retrieveTerm('ownerInstitutionCode')! />
  <#if ownerInstitutionCode?has_content>
      <h3>Owner Institution Code</h3>
      <p>${ownerInstitutionCode}</p>
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

<#if verbatim["GeologicalContext"]??>
  <#-- show additional geological context group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="geology" title="Geological context">
    <div class="left">

      <#assign earliestEonOrLowestEonothem = action.retrieveTerm('earliestEonOrLowestEonothem')! />
      <#assign latestEonOrHighestEonothem = action.retrieveTerm('latestEonOrHighestEonothem')! />
      <#if earliestEonOrLowestEonothem?has_content || latestEonOrHighestEonothem?has_content>
        <#if earliestEonOrLowestEonothem?has_content && latestEonOrHighestEonothem?has_content>
          <h3>Earliest Eon Or Lowest Eonothem / Latest Eon Or Highest Eonothem</h3>
          <p>${earliestEonOrLowestEonothem}&nbsp;/&nbsp;${latestEonOrHighestEonothem}</p>
        <#elseif earliestEonOrLowestEonothem?has_content>
          <h3>Earliest Eon Or Lowest Eonothem</h3>
          <p>${earliestEonOrLowestEonothem}</p>
        <#elseif latestEonOrHighestEonothem?has_content>
          <h3>Latest Eon Or Highest Eonothem</h3>
          <p>${latestEonOrHighestEonothem}</p>
        </#if>
      </#if>

      <#assign earliestEraOrLowestErathem = action.retrieveTerm('earliestEraOrLowestErathem')! />
      <#assign latestEraOrHighestErathem = action.retrieveTerm('latestEraOrHighestErathem')! />
      <#if earliestEraOrLowestErathem?has_content || latestEraOrHighestErathem?has_content>
        <#if earliestEraOrLowestErathem?has_content && latestEraOrHighestErathem?has_content>
            <h3>Earliest Era Or Lowest Erathem / Latest Era Or Highest Erathem</h3>
            <p>${earliestEraOrLowestErathem}&nbsp;/&nbsp;${latestEraOrHighestErathem}</p>
        <#elseif earliestEraOrLowestErathem?has_content>
            <h3>Earliest Era Or Lowest Erathem</h3>
            <p>${earliestEonOrLowestEonothem}</p>
        <#elseif latestEraOrHighestErathem?has_content>
            <h3>Latest Era Or Highest Erathem</h3>
            <p>${latestEraOrHighestErathem}</p>
        </#if>
      </#if>

      <#assign earliestPeriodOrLowestSystem = action.retrieveTerm('earliestPeriodOrLowestSystem')! />
      <#assign latestPeriodOrHighestSystem = action.retrieveTerm('latestPeriodOrHighestSystem')! />
      <#if earliestPeriodOrLowestSystem?has_content || latestPeriodOrHighestSystem?has_content>
        <#if earliestPeriodOrLowestSystem?has_content && latestPeriodOrHighestSystem?has_content>
            <h3>Earliest Period Or Lowest System / Latest Period Or Highest System</h3>
            <p>${earliestPeriodOrLowestSystem}&nbsp;/&nbsp;${latestPeriodOrHighestSystem}</p>
        <#elseif earliestPeriodOrLowestSystem?has_content>
            <h3>Earliest Period Or Lowest System</h3>
            <p>${earliestPeriodOrLowestSystem}</p>
        <#elseif latestPeriodOrHighestSystem?has_content>
            <h3>Latest Period Or Highest System</h3>
            <p>${latestPeriodOrHighestSystem}</p>
        </#if>
      </#if>

      <#assign earliestEpochOrLowestSeries = action.retrieveTerm('earliestEpochOrLowestSeries')! />
      <#assign latestEpochOrHighestSeries = action.retrieveTerm('latestEpochOrHighestSeries')! />
      <#if earliestEpochOrLowestSeries?has_content || latestEpochOrHighestSeries?has_content>
        <#if earliestEpochOrLowestSeries?has_content && latestEpochOrHighestSeries?has_content>
            <h3>Earliest Epoch Or Lowest Series / Latest Epoch Or Highest Series</h3>
            <p>${earliestEpochOrLowestSeries}&nbsp;/&nbsp;${latestEpochOrHighestSeries}</p>
        <#elseif earliestEpochOrLowestSeries?has_content>
            <h3>Earliest Epoch Or Lowest Series</h3>
            <p>${earliestEpochOrLowestSeries}</p>
        <#elseif latestEpochOrHighestSeries?has_content>
            <h3>Latest Epoch Or Highest Series</h3>
            <p>${latestEpochOrHighestSeries}</p>
        </#if>
      </#if>


      <#assign earliestAgeOrLowestStage = action.retrieveTerm('earliestAgeOrLowestStage')! />
      <#assign latestAgeOrHighestStage = action.retrieveTerm('latestAgeOrHighestStage')! />
      <#if earliestAgeOrLowestStage?has_content || latestAgeOrHighestStage?has_content>
        <#if earliestAgeOrLowestStage?has_content && latestAgeOrHighestStage?has_content>
            <h3>Earliest Age Or Lowest Stage / Latest Age Or Highest Stage</h3>
            <p>${earliestAgeOrLowestStage}&nbsp;/&nbsp;${latestAgeOrHighestStage}</p>
        <#elseif earliestAgeOrLowestStage?has_content>
            <h3>Earliest Age Or Lowest Stage</h3>
            <p>${earliestAgeOrLowestStage}</p>
        <#elseif latestAgeOrHighestStage?has_content>
            <h3>Latest Age Or Highest Stage</h3>
            <p>${latestAgeOrHighestStage}</p>
        </#if>
      </#if>


      <#assign lowestBiostratigraphicZone = action.retrieveTerm('lowestBiostratigraphicZone')! />
      <#assign highestBiostratigraphicZone = action.retrieveTerm('highestBiostratigraphicZone')! />
      <#if lowestBiostratigraphicZone?has_content || highestBiostratigraphicZone?has_content>
        <#if lowestBiostratigraphicZone?has_content && highestBiostratigraphicZone?has_content>
            <h3>Lowest Biostratigraphic Zone / Highest Biostratigraphic Zone</h3>
            <p>${lowestBiostratigraphicZone}&nbsp;/&nbsp;${highestBiostratigraphicZone}</p>
        <#elseif lowestBiostratigraphicZone?has_content>
            <h3>Lowest Biostratigraphic Zone</h3>
            <p>${lowestBiostratigraphicZone}</p>
        <#elseif highestBiostratigraphicZone?has_content>
            <h3>Highest Biostratigraphic Zone</h3>
            <p>${highestBiostratigraphicZone}</p>
        </#if>
      </#if>

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

<#--<#assign associatedMedia = action.retrieveTerm('associatedMedia')! />-->
<#--<#if associatedMedia?? || (occ.media?size > 0) >-->
  <#--<@common.article id="media" title="Media">-->

  <#--&lt;#&ndash; show list of images coming in from DwC associatedMedia. Todo: show actual images &ndash;&gt;-->
  <#--<#if associatedMedia??>-->
    <#--<h3>Associated Media</h3>-->
    <#--<p>${associatedMedia}</p>-->
  <#--</#if>-->

  <#--&lt;#&ndash; show list of media. Todo: show actual images &ndash;&gt;-->
  <#--<#if (occ.media?size > 0)>-->
    <#--<#list occ.media as m>-->
      <#--<h3>Image #${m_index+1}: ${m.title!"No title"}</h3>-->

        <#--<#if m.image?has_content>-->
        <#--<p><a href="${m.image}">${m.image}</a></p>-->
        <#--</#if>-->

        <#--<#if m.created?has_content>-->
        <#--<h3>Taken on</h3>-->
        <#--<p>${m.created?date?string.medium}</p>-->
        <#--</#if>-->

        <#--<#if m.creator?has_content>-->
        <#--<h3>Photographer</h3>-->
        <#--<p>${m.creator}</p>-->
        <#--</#if>-->

        <#--<#if m.publisher?has_content>-->
        <#--<h3>Publisher</h3>-->
        <#--<p>${m.publisher}</p>-->
        <#--</#if>-->

        <#--<#if m.description?has_content>-->
        <#--<h3>Description</h3>-->
        <#--<p>${m.description}</p>-->
        <#--</#if>-->

        <#--<#if m.license?has_content>-->
        <#--<h3>Copyright</h3>-->
        <#--<p>${m.license}</p>-->
        <#--</#if>-->

      <#--<a href="${m.image}" class="read_more">Read more</a>-->
      <#--</#list>-->
    <#--</#if>-->
  <#--</@common.article>-->
<#--</#if>-->

<#--<#if (occ.facts?size > 0) >-->
  <#--<@common.article id="measurementOrFact" title="Measurement or fact">-->

  <#--&lt;#&ndash; show list of FactOrMeasurement. &ndash;&gt;-->
    <#--<#if (occ.facts?size > 0)>-->
      <#--<#list occ.facts as fom>-->
      <#--<h3>Fact or Measurement #${fom_index+1}: ${fom.type!"Type unknown"}</h3>-->

        <#--<#if fom.value?has_content>-->
        <#--<p>${fom.value}</p>-->
        <#--</#if>-->

        <#--<#if fom.unit?has_content>-->
        <#--<h3>Unit</h3>-->
        <#--<p>${fom.unit}</p>-->
        <#--</#if>-->

        <#--<#if fom.accuracy?has_content>-->
        <#--<h3>Accuracy</h3>-->
        <#--<p>${fom.accuracy}</p>-->
        <#--</#if>-->

        <#--<#if fom.method?has_content>-->
        <#--<h3>Method</h3>-->
        <#--<p>${fom.method}</p>-->
        <#--</#if>-->

        <#--<#if fom.determinedBy?has_content>-->
        <#--<h3>Determined By</h3>-->
        <#--<p>${fom.determinedBy}</p>-->
        <#--</#if>-->

        <#--<#if fom.determinedDate?has_content>-->
        <#--<h3>Date Determined</h3>-->
        <#--<p>${fom.determinedDate}</p>-->
        <#--</#if>-->

        <#--<#if fom.remarks?has_content>-->
        <#--<h3>Remarks</h3>-->
        <#--<p>${fom.remarks}</p>-->
        <#--</#if>-->

      <#--</#list>-->
    <#--</#if>-->
  <#--</@common.article>-->
<#--</#if>-->

<#--<#if (occ.relations?size > 0) >-->
  <#--<@common.article id="resourceRelationship" title="Resource Relationship">-->

  <#--&lt;#&ndash; show list of FactOrMeasurement. &ndash;&gt;-->
    <#--<#if (occ.relations?size > 0)>-->
      <#--<#list occ.relations as r>-->
      <#--<h3>Occurrence relation #${r_index+1}: ${r.id!"ID unknown"}</h3>-->

        <#--<#if r.occurrenceId?has_content>-->
        <#--<p>${r.occurrenceId}</p>-->
        <#--</#if>-->

        <#--<#if r.type?has_content>-->
        <#--<p>${r.type}</p>-->
        <#--</#if>-->

        <#--<#if r.relatedOccurrenceId?has_content>-->
        <#--<p>${r.relatedOccurrenceId}</p>-->
        <#--</#if>-->

        <#--<#if r.accordingTo?has_content>-->
        <#--<h3>According to</h3>-->
        <#--<p>${r.accordingTo}</p>-->
        <#--</#if>-->

        <#--<#if r.establishedDate?has_content>-->
        <#--<h3>Date established</h3>-->
        <#--<p>${r.establishedDate}</p>-->
        <#--</#if>-->

        <#--<#if r.remarks?has_content>-->
        <#--<h3>Remarks</h3>-->
        <#--<p>${r.remarks}</p>-->
        <#--</#if>-->

      <#--</#list>-->
    <#--</#if>-->
  <#--</@common.article>-->
<#--</#if>-->

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
