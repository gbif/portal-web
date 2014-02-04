<#-- @ftlvariable name="" type="org.gbif.portal.action.occurrence.DetailAction" -->
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

<#macro kv header value="" term="" plusMinus="">
  <#assign retrieved = "" />
  <#if term?has_content>
    <#assign retrieved = action.retrieveTerm(term)!"" />
  </#if>
  <#if retrieved?has_content || value?has_content>
    <h3>${header}</h3>
    <#-- retrieve value from term, otherwise use incoming value -->
    <p><#if retrieved?has_content>${retrieved}<#else>${value}<#if plusMinus?has_content>m&nbsp;±&nbsp;${plusMinus}</#if></#if></p>
  </#if>
</#macro>

<#macro footprint header wkt srs fit>
  <#if wkt?has_content || srs?has_content || fit?has_content>
  <h3>${header}</h3>
  <p>
    <dl>
      <#if wkt?has_content>
          <dt>WKT</dt>
          <dd>${wkt}</dd>
      </#if>

      <#if srs?has_content>
        <dt>SRS</dt>
        <dd>${srs}</dd>
      </#if>

      <#if fit?has_content>
        <dt>Spatial Fit</dt>
        <dd>${fit}</dd>
      </#if>
    </dl>
  </p>
  </#if>
</#macro>

<#macro georeferenced header georeferencedDate georeferencedBy georeferenceProtocol georeferenceSources georeferenceVerificationStatus>
  <#if georeferencedDate?has_content || georeferencedBy?has_content || georeferenceProtocol?has_content || georeferenceSources?has_content || georeferenceVerificationStatus?has_content>
  <h3>${header}</h3>
  <p>
  <dl>
    <#if georeferencedDate?has_content || georeferencedBy?has_content>
        <dt>Georeferenced</dt>
        <dd>
          <#if georeferencedDate?has_content && georeferencedBy?has_content>
            ${georeferencedDate}&nbsp;by&nbsp;${georeferencedBy}
          <#elseif georeferencedDate?has_content>
            ${georeferencedDate}
          <#elseif georeferencedBy?has_content>
            By&nbsp;${georeferencedBy}
          </#if>
        </dd>
    </#if>

    <#if georeferenceProtocol?has_content>
      <dt>Protocol</dt>
      <dd>${georeferenceProtocol}</dd>
    </#if>

    <#if georeferenceSources?has_content>
        <dt>Sources</dt>
        <dd>${georeferenceSources}</dd>
    </#if>

    <#if georeferenceVerificationStatus?has_content>
        <dt>Status</dt>
        <dd>${georeferenceVerificationStatus}</dd>
    </#if>
  </dl>
  </p>
  </#if>
</#macro>

<#assign locality = action.retrieveTerm('locality')! />
<#assign island = action.retrieveTerm('island')! />
<#assign islandGroup = action.retrieveTerm('islandGroup')! />
<#assign footprintWKT = action.retrieveTerm('footprintWKT')! />
<#assign footprintSRS = action.retrieveTerm('footprintSRS')! />
<#assign footprintSpatialFit = action.retrieveTerm('footprintSpatialFit')! />
<#assign georeferencedDate = action.retrieveTerm('georeferencedDate')! />
<#assign georeferencedBy = action.retrieveTerm('georeferencedBy')! />
<#assign georeferenceProtocol = action.retrieveTerm('georeferenceProtocol')! />
<#assign georeferenceSources = action.retrieveTerm('georeferenceSources')! />
<#assign georeferenceVerificationStatus = action.retrieveTerm('georeferenceVerificationStatus')! />

<@common.article id="location" title=title titleRight=titleRight class="occurrenceMap">
  <#if showMap>
    <div id="map" class="map">
      <iframe id="mapframe" name="mapframe" src="${cfg.tileServerBaseUrl!}/point.html?&style=grey-blue&point=${occ.latitude?c},${occ.longitude?c}&lat=${occ.latitude?c}&lng=${occ.longitude?c}&zoom=8" height="100%" width="100%" frameborder="0"/></iframe>
    </div>

    <div class="right">
     <div class="scrollable330">

      <h3>Locality</h3>
      <p class="no_bottom">${locality!}<#if occ.country??><#if locality?has_content>, </#if><a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></#if></p>
      <p class="light_note">${occ.longitude}, ${occ.latitude} <#if occ.coordinateAccuracy??> ± ${occ.coordinateAccuracy!?string}</#if></p>

      <@kv header="Water Body" value=occ.waterBody />
      <@kv header="Altitude" value=occ.altitude plusMinus=occ.altitudeAccuracy!?string />
      <@kv header="Depth" value=occ.depth plusMinus=occ.depthAccuracy!?string />

      <#-- TODO: maximum distance above surface with accuracy, see http://dev.gbif.org/issues/browse/POR-1746 -->

      </div>
    </div>
    <div class="fullwidth fullwidth_under_map">
      <div class="left left_under_map left_occurrence_detail">
        <@geoClassification header="Geographic Classification" geographicClassification=geographicClassification/>
        <@islandClassification header="Islands" island=island islandGroup=islandGroup />
        <@kv header="Habitat" term='habitat' />
        <@footprint header="Footprint" wkt=footprintWKT srs=footprintSRS fit=footprintSpatialFit />
        <@georeferenced header="Georeference" georeferencedDate=georeferencedDate georeferencedBy=georeferencedBy georeferenceProtocol=georeferenceProtocol georeferenceSources=georeferenceSources georeferenceVerificationStatus=georeferenceVerificationStatus />
        <@kv header="Remarks" term='locationRemarks' />
     </div>

     <div class="right right_under_map">
       <@kv header="Higher Geography ID" term='higherGeographyID' />
       <@kv header="Location ID" term='locationID' />
       <@kv header="Location According To" term='locationAccordingTo' />
     </div>
  </div>

  <#else>
    <div class="fullwidth fullwidth_under_map left_occurrence_detail">

    <div class="left">
      <@kv header="Locality" term='locality' />
      <@kv header="Altitude" value=occ.altitude plusMinus=occ.altitudeAccuracy!?string />
      <@kv header="Depth" value=occ.depth plusMinus=occ.depthAccuracy!?string />
      <@kv header="Water Body" value=occ.waterBody />
      <@geoClassification header="Geographic Classification" geographicClassification=geographicClassification/>
      <@islandClassification header="Islands" island=island islandGroup=islandGroup />
      <@kv header="Habitat" term='habitat' />
      <@footprint header="Footprint" wkt=footprintWKT srs=footprintSRS fit=footprintSpatialFit />
      <@georeferenced header="Georeference" georeferencedDate=georeferencedDate georeferencedBy=georeferencedBy georeferenceProtocol=georeferenceProtocol georeferenceSources=georeferenceSources georeferenceVerificationStatus=georeferenceVerificationStatus />
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

      <@kv header="Previous Identifications" term='previousIdentifications' />
      <@kv header="References" term='identificationReferences' />
      <@kv header="Remarks" term='identificationRemarks' />

    </div>
    <div class="right">

      <#assign identifiedBy = action.retrieveTerm('identifiedBy')! />
      <#if occ.dateIdentified?? && identifiedBy?has_content>
        <@kv header="Identified" value=occ.dateIdentified!?date?string.medium!  + " by " + identifiedBy />
      <#elseif occ.dateIdentified??>
        <@kv header="Identified" value=occ.dateIdentified!?date?string.medium! />
      <#elseif identifiedBy?has_content>
        <@kv header="Identified" value="By " + identifiedBy />
      </#if>

      <@kv header="Individual ID" term='individualID' />
      <@kv header="Identification ID" term='identificationID' />
      <@kv header="Verification Status" term='identificationVerificationStatus' />
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
          <p>${occ.eventDate!?datetime?string.medium}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
        <#elseif partialGatheringDate?has_content >
          <p>${partialGatheringDate}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
        <#elseif verbatimEventDate?has_content >
            <p>${verbatimEventDate}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
        <#else>
          <p>By&nbsp;${recordedBy}</p>
        </#if>
      </#if>

      <@kv header="Associated Occurrences" term='associatedOccurrences' />
      <@kv header="Associated Sequences" term='associatedSequences' />
      <@kv header="Associated References" term='associatedReferences' />
      <@kv header="Associated Taxa" term='associatedTaxa' />
      <@kv header="Sampling Protocol" term='samplingProtocol' />
      <@kv header="Sampling Effort" term='samplingEffort' />
      <@kv header="Field Notes" term='fieldNotes' />

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
    <@kv header="Life Stage" value=occ.lifeStage!?string?lower_case?cap_first />
    <@kv header="Sex" value=occ.sex!?string?lower_case?cap_first />
    <@kv header="Establishment Means" value=occ.establishmentMeans!?string?lower_case?cap_first />
    <@kv header="Reproductive Condition" term='reproductiveCondition' />
    <@kv header="Individual Count" value=occ.individualCount />
    <@kv header="Behavior" term='behavior' />
    <@kv header="Occurrence Status" term='occurrenceStatus' />
    <@kv header="Record Number" term='recordNumber' />
    <@kv header="Event ID" term='eventID' />
    <@kv header="Field Number" term='fieldNumber' />
  </div>

</@common.article>

<@common.article id="source" title="Source details">
<div class="left">
    <h3>Data publisher</h3>
    <p><a href="<@s.url value='/publisher/${publisher.key}'/>" title="">${publisher.title}</a></p>

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

  <@kv header="Owner Institution Code" term='ownerInstitutionCode' />

  <h3>Dataset</h3>
  <p><a href="<@s.url value='/dataset/${dataset.key}'/>" title="">${dataset.title}</a></p>

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

  <@kv header="Disposition" term='disposition' />
  <@kv header="Preparations" term='preparations' />
  <@kv header="Data Generalizations" term='dataGeneralizations' />
  <@kv header="Information Withheld" term='informationWithheld' />
  <@kv header="Dynamic Properties" term='dynamicProperties' />
</div>

<div class="right">

  <@kv header="Occurrence ID" term='occurrenceID' />

  <h3>GBIF ID</h3>
  <p>${id?c}</p>

  <@kv header="Catalog number" term='catalogNumber' />
  <@kv header="Other Catalog numbers" term='otherCatalogNumbers' />

  <#list occ.identifiers as i>
      <h3>${i.type}</h3>
      <p>${i.identifier}</p>
  </#list>

  <@kv header="Language" term='language' />
</div>

</@common.article>

<#if verbatim["GeologicalContext"]??>
  <#-- show additional geological context group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="geology" title="Geological context">
    <div class="left left_occurrence_detail">

      <#assign earliestEonOrLowestEonothem = action.retrieveTerm('earliestEonOrLowestEonothem')! />
      <#assign latestEonOrHighestEonothem = action.retrieveTerm('latestEonOrHighestEonothem')! />

      <#assign earliestEraOrLowestErathem = action.retrieveTerm('earliestEraOrLowestErathem')! />
      <#assign latestEraOrHighestErathem = action.retrieveTerm('latestEraOrHighestErathem')! />

      <#assign earliestPeriodOrLowestSystem = action.retrieveTerm('earliestPeriodOrLowestSystem')! />
      <#assign latestPeriodOrHighestSystem = action.retrieveTerm('latestPeriodOrHighestSystem')! />

      <#assign earliestEpochOrLowestSeries = action.retrieveTerm('earliestEpochOrLowestSeries')! />
      <#assign latestEpochOrHighestSeries = action.retrieveTerm('latestEpochOrHighestSeries')! />

      <#assign earliestAgeOrLowestStage = action.retrieveTerm('earliestAgeOrLowestStage')! />
      <#assign latestAgeOrHighestStage = action.retrieveTerm('latestAgeOrHighestStage')! />

      <#if earliestEonOrLowestEonothem?has_content || latestEonOrHighestEonothem?has_content ||
      earliestEraOrLowestErathem?has_content || latestEraOrHighestErathem?has_content ||
      earliestPeriodOrLowestSystem?has_content || latestPeriodOrHighestSystem?has_content ||
      earliestEpochOrLowestSeries?has_content || latestEpochOrHighestSeries?has_content ||
      earliestAgeOrLowestStage?has_content || latestAgeOrHighestStage?has_content>
        <h3>Stratigraphic Classification</h3>
          <p>
          <dl>
            <#if earliestEonOrLowestEonothem?has_content || latestEonOrHighestEonothem?has_content>
              <dt>Eon</dt>
              <dd>
                  ${earliestEonOrLowestEonothem!}
                  <#if earliestEonOrLowestEonothem?has_content && latestEonOrHighestEonothem?has_content>-</#if>
                  ${latestEonOrHighestEonothem!}
              </dd>
            </#if>

            <#if earliestEraOrLowestErathem?has_content || latestEraOrHighestErathem?has_content>
              <dt>Era</dt>
              <dd>
                  ${earliestEonOrLowestEonothem!}
                  <#if earliestEraOrLowestErathem?has_content && latestEraOrHighestErathem?has_content>-</#if>
                  ${latestEraOrHighestErathem!}
              </dd>
            </#if>

            <#if earliestPeriodOrLowestSystem?has_content || latestPeriodOrHighestSystem?has_content>
              <dt>Period</dt>
              <dd>
                  ${earliestPeriodOrLowestSystem!}
                  <#if earliestPeriodOrLowestSystem?has_content && latestPeriodOrHighestSystem?has_content>-</#if>
                  ${latestPeriodOrHighestSystem!}
              </dd>
            </#if>

            <#if earliestEpochOrLowestSeries?has_content || latestEpochOrHighestSeries?has_content>
              <dt>Epoch</dt>
              <dd>
                  ${earliestEpochOrLowestSeries!}
                  <#if earliestEpochOrLowestSeries?has_content && latestEpochOrHighestSeries?has_content>-</#if>
                  ${latestEpochOrHighestSeries!}
              </dd>
            </#if>

            <#if earliestAgeOrLowestStage?has_content || latestAgeOrHighestStage?has_content>
              <dt>Age</dt>
              <dd>
                  ${earliestAgeOrLowestStage!}
                  <#if earliestAgeOrLowestStage?has_content && latestAgeOrHighestStage?has_content>-</#if>
                  ${latestAgeOrHighestStage!}
              </dd>
            </#if>
          </dl>
          </p>
      </#if>

      <#assign lowestBiostratigraphicZone = action.retrieveTerm('lowestBiostratigraphicZone')! />
      <#assign highestBiostratigraphicZone = action.retrieveTerm('highestBiostratigraphicZone')! />
      <#if lowestBiostratigraphicZone?has_content || highestBiostratigraphicZone?has_content>
        <h3>Biostratigraphic Zone</h3>
        <#if lowestBiostratigraphicZone?has_content && highestBiostratigraphicZone?has_content>
            <p>${lowestBiostratigraphicZone}&nbsp;/&nbsp;${highestBiostratigraphicZone}</p>
        <#elseif lowestBiostratigraphicZone?has_content>
            <p>${lowestBiostratigraphicZone}</p>
        <#elseif highestBiostratigraphicZone?has_content>
            <p>${highestBiostratigraphicZone}</p>
        </#if>
      </#if>

      <@kv header="Bed" term='bed' />
      <@kv header="Formation" term='formation' />
      <@kv header="Group" term='group' />
      <@kv header="Member" term='member' />
    </div>

    <div class="right">
      <@kv header="Geological Context ID" term='geologicalContextID' />
      <@kv header="Lithostratigraphic Terms" term='lithostratigraphicTerms' />
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

<@common.notice title="Record history">
  <p>
    This record was last modified in GBIF on ${occ.lastInterpreted?date?string.medium}.
    The source was last visited by GBIF on ${occ.lastCrawled?date?string.medium}.
    <#if occ.modified??>
      It was last updated by the publisher on ${occ.modified?date?string.medium}.
    </#if>
  </p>
  <p>A record will be modified by GBIF when either the source record has been changed by the publisher, or improvements in the GBIF processing warrant an update.</p>

  <p>There may be more details available about this occurrence in the <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>">verbatim version</a> of the record</p>
</@common.notice>


<#if occ.issues?has_content>
<@common.notice title="Interpretation issues">
  <a name="issues"/>
  <p>GBIF found issues interpreting the <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>">verbatim content</a> of this record:</p>
  <ul>
  <#list occ.issues as issue>
    <li><p>${issue.name()?replace("_", " ")?capitalize}</p></li>
  </#list>
  </ul>
</@common.notice>
</#if>

</body>
</html>
