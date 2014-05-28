<#-- @ftlvariable name="" type="org.gbif.portal.action.occurrence.DetailAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<#assign showMap=occ.decimalLongitude?? && occ.decimalLatitude??/>
<html>
<head>
  <title>Occurrence Detail ${id?c}</title>

  <!-- Extra content used for the image gallery only-->
  <content tag="extra_scripts">
    <#-- shadowbox to view large images -->
    <link rel="stylesheet" type="text/css" href="<@s.url value='/js/vendor/fancybox/jquery.fancybox.css?v=2.1.4'/>">
    <script type="text/javascript" src="<@s.url value='/js/vendor/fancybox/jquery.fancybox.js?v=2.1.4'/>"></script>
    <link rel="stylesheet" type="text/css" href="<@s.url value='/js/vendor/fancybox/helpers/jquery.fancybox-buttons.css?v=1.0.5'/>">
    <script type="text/javascript" src="<@s.url value='/js/vendor/fancybox/helpers/jquery.fancybox-buttons.js?v=1.0.5'/>"></script>

    <script type="text/javascript">
      $(function() {
        var imagesJSON = '{"results": ${media}}';
        if (imagesJSON) {
          $("#images").occurrenceSlideshow(imagesJSON, '${action.verbatimValue('scientificName')!occ.scientificName!"No title"}');
        }
      });
    </script>
    <style type="text/css">
        #content #images .scrollable {
          height: 350px;
        }
        /* specific to this page, since it falls right beside a high z-order map article */
        .fancybox-overlay {
          z-index: 10001;
        }
      #content #media dl dd:last-child {
        margin-bottom: 30px;
      }
    </style>
  </content>

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
  <#if geographicClassification?has_content >
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

<#macro kv header value="" plusMinus="" unit="">
  <#if value?has_content>
    <h3>${header}</h3>
    <p><#if value?starts_with("http")><a href="${value}">${value}</a><#else>${value}</#if>${unit!}<#if plusMinus?has_content>&nbsp;±&nbsp;${plusMinus}${unit!}</#if></p>
  </#if>
</#macro>

<#macro footprint header wkt srs fit>
  <#if wkt?has_content || srs?has_content || fit?has_content>
  <h3>${header}</h3>
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
  </#if>
</#macro>

<#assign locality = action.termValue('locality')! />
<#assign island = action.termValue('island')! />
<#assign islandGroup = action.termValue('islandGroup')! />
<#assign footprintWKT = action.termValue('footprintWKT')! />
<#assign footprintSRS = action.termValue('footprintSRS')! />
<#assign footprintSpatialFit = action.termValue('footprintSpatialFit')! />
<#assign georeferencedDate = action.termValue('georeferencedDate')! />
<#assign georeferencedBy = action.termValue('georeferencedBy')! />
<#assign georeferenceProtocol = action.termValue('georeferenceProtocol')! />
<#assign georeferenceSources = action.termValue('georeferenceSources')! />
<#assign georeferenceVerificationStatus = action.termValue('georeferenceVerificationStatus')! />
<#assign habitat = action.termValue('habitat')! />
<#assign locationRemarks = action.termValue('locationRemarks')! />
<#assign higherGeographyID = action.termValue('higherGeographyID')! />
<#assign locationID = action.termValue('locationID')! />
<#assign locationAccordingTo = action.termValue('locationAccordingTo')! />

<#-- Location block consists of max 25 terms/fields. At least 1 has to be present for block to appear -->
<#if locality?has_content || island?has_content || islandGroup?has_content || footprintWKT?has_content ||
  footprintSRS?has_content || footprintSpatialFit?has_content || georeferencedDate?has_content ||
  georeferencedBy?has_content || georeferenceProtocol?has_content || georeferenceSources?has_content ||
  georeferenceVerificationStatus?has_content || habitat?has_content || locationRemarks?has_content ||
  higherGeographyID?has_content || locationID?has_content || locationAccordingTo?has_content ||
  occ.decimalLatitude?has_content || occ.decimalLongitude?has_content || occ.country?has_content ||
  occ.waterBody?has_content || occ.elevation?has_content || occ.elevationAccuracy?has_content ||
  occ.depth?has_content || occ.depthAccuracy?has_content || geographicClassification?has_content >

  <#macro georeferenced>
    <#if georeferencedDate?has_content || georeferencedBy?has_content || georeferenceProtocol?has_content || georeferenceSources?has_content || georeferenceVerificationStatus?has_content>
      <h3>Georeferencing</h3>
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
    </#if>
  </#macro>

  <@common.article id="location" title=title titleRight=titleRight class="occurrenceMap">
    <#if showMap>
    <div id="map" class="map">
        <iframe id="mapframe" name="mapframe" src="${cfg.tileServerBaseUrl!}/point.html?&style=grey-blue&point=${occ.decimalLatitude?c},${occ.decimalLongitude?c}&lat=${occ.decimalLatitude?c}&lng=${occ.decimalLongitude?c}&zoom=8" height="100%" width="100%" frameborder="0"/></iframe>
    </div>

    <div class="right">
        <div class="scrollable330">

            <h3>Locality</h3>
            <p class="no_bottom">${locality!}<#if occ.country??><#if locality?has_content>, </#if><a href="<@s.url value='/country/${occ.country.iso2LetterCode}'/>">${occ.country.title}</a></#if></p>
            <#if occ.decimalLongitude?has_content>
              <p class="light_note">${occ.decimalLongitude?c}, ${occ.decimalLatitude?c} <#if occ.coordinateAccuracy??> ± ${occ.coordinateAccuracy!?string}</#if></p>
            </#if>

          <@kv header="Water Body" value=occ.waterBody />
          <@kv header="Elevation" value=occ.elevation unit="m" plusMinus=occ.elevationAccuracy!?string />
          <@kv header="Depth" value=occ.depth unit="m" plusMinus=occ.depthAccuracy!?string />
        </div>
    </div>
    <div class="fullwidth fullwidth_under_map">
        <div class="left left_under_map">
          <@geoClassification header="Geographic Classification" geographicClassification=geographicClassification/>
        <@islandClassification header="Islands" island=island islandGroup=islandGroup />
        <@kv header="Habitat" value=habitat />
        <@footprint header="Footprint" wkt=footprintWKT srs=footprintSRS fit=footprintSpatialFit />
        <@georeferenced />
        <@kv header="Remarks" value=locationRemarks />
        </div>

        <div class="right right_under_map">
          <@kv header="Higher Geography ID" value=higherGeographyID />
       <@kv header="Location ID" value=locationID />
       <@kv header="Location According To" value=locationAccordingTo />
        </div>
    </div>

    <#else>
    <div class="fullwidth fullwidth_under_map">
        <div class="left">
          <@kv header="Locality" value=locality />
      <@kv header="Elevation" value=occ.elevation unit="m" plusMinus=occ.elevationAccuracy!?string />
      <@kv header="Depth" value=occ.depth unit="m" plusMinus=occ.depthAccuracy!?string />
      <@kv header="Water Body" value=occ.waterBody />
      <@geoClassification header="Geographic Classification" geographicClassification=geographicClassification/>
      <@islandClassification header="Islands" island=island islandGroup=islandGroup />
      <@kv header="Habitat" value=habitat />
      <@footprint header="Footprint" wkt=footprintWKT srs=footprintSRS fit=footprintSpatialFit />
      <@georeferenced />
      <@kv header="Remarks" value=locationRemarks />
        </div>
        <div class="right right_under_map">
          <@kv header="Higher Geography ID" value=higherGeographyID />
      <@kv header="Location ID" value=locationID />
      <@kv header="Location According To" value=locationAccordingTo />
        </div>
    </div>
    </#if>
  </@common.article>
</#if>


<!-- Start a gallery, only if the occurrence has at least 1 image media -->
<#if action.hasImages()>
  <@common.article id="images">
    <div class="species_images">
      <a class="controller previous" href="#" title="Previous image"></a>
      <a class="controller next" href="#" title="Next image"></a>
      <div class="scroller">
        <div class="photos"></div>
      </div>
    </div>
    <div class="right">
      <h2 class="title"></h2>
      <div class="scrollable"></div>
    </div>
    <div class="counter">1 / 1</div>
  </@common.article>
</#if>

<#assign previousIdentifications = action.termValue('previousIdentifications')! />
<#assign identificationReferences = action.termValue('identificationReferences')! />
<#assign identificationRemarks = action.termValue('identificationRemarks')! />
<#assign individualID = action.termValue('individualID')! />
<#assign identificationID = action.termValue('identificationID')! />
<#assign identificationVerificationStatus = action.termValue('identificationVerificationStatus')! />
<#assign identifiedBy = action.termValue('identifiedBy')! />

<#-- Identification block consists of various terms/fields. At least 1 has to be present for block to appear -->
<#if occ.taxonKey?? || occ.typeStatus?has_content || occ.dateIdentified?has_content ||
previousIdentifications?has_content || identificationReferences?has_content || identificationRemarks?has_content ||
individualID?has_content || identificationID?has_content || identificationVerificationStatus?has_content ||
identifiedBy?has_content>
  <#assign title>
  Identification details <span class='subtitle'>According to <a href="<@s.url value='/dataset/${nubDatasetKey}'/>">GBIF Backbone Taxonomy</a></span>
  </#assign>
  <@common.article id="taxonomy" title=title>
  <div class="left">
    <#if occ.taxonKey??>
      <#assign identificationQualifier = action.termValue('identificationQualifier')! />
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

    <@kv header="Previous Identifications" value=previousIdentifications />
    <@kv header="References" value=identificationReferences />
    <@kv header="Remarks" value=identificationRemarks />

  </div>
  <div class="right">

      <#if occ.dateIdentified?? && identifiedBy?has_content>
    <@kv header="Identified" value=occ.dateIdentified!?date?string.medium!  + " by " + identifiedBy />
  <#elseif occ.dateIdentified??>
    <@kv header="Identified" value=occ.dateIdentified!?date?string.medium! />
  <#elseif identifiedBy?has_content>
    <@kv header="Identified" value="By " + identifiedBy />
  </#if>

      <@kv header="Individual ID" value=individualID />
      <@kv header="Identification ID" value=identificationID />
      <@kv header="Verification Status" value=identificationVerificationStatus />
  </div>

  </@common.article>
</#if>


<#assign recordedBy = action.termValue('recordedBy')! />
<#assign verbatimEventDate = action.termValue('verbatimEventDate')! />
<#assign occurrenceRemarks = action.termValue('occurrenceRemarks')! />
<#assign eventRemarks = action.termValue('eventRemarks')! />
<#assign associatedOccurrences = action.termValue('associatedOccurrences')! />
<#assign associatedSequences = action.termValue('associatedSequences')! />
<#assign associatedReferences = action.termValue('associatedReferences')! />
<#assign associatedTaxa = action.termValue('associatedTaxa')! />
<#assign samplingProtocol = action.termValue('samplingProtocol')! />
<#assign samplingEffort = action.termValue('samplingEffort')! />
<#assign fieldNotes = action.termValue('fieldNotes')! />
<#assign reproductiveCondition = action.termValue('reproductiveCondition')! />
<#assign behavior = action.termValue('behavior')! />
<#assign occurrenceStatus = action.termValue('occurrenceStatus')! />
<#assign recordNumber = action.termValue('recordNumber')! />
<#assign eventID = action.termValue('eventID')! />
<#assign fieldNumber = action.termValue('fieldNumber')! />
<#assign eventDate = occ.eventDate! />

<#-- Occurrence block consists of various terms/fields. At least 1 has to be present for block to appear -->
<#if occ.lifeStage?has_content || occ.sex?has_content || occ.establishmentMeans?has_content ||
occ.individualCount?has_content ||recordedBy?has_content || verbatimEventDate?has_content || eventDate?has_content ||
occurrenceRemarks?has_content || eventRemarks?has_content || associatedOccurrences?has_content ||
partialGatheringDate?has_content || associatedSequences?has_content || associatedReferences?has_content ||
associatedTaxa?has_content || samplingProtocol?has_content || samplingEffort?has_content || fieldNotes?has_content ||
reproductiveCondition?has_content || behavior?has_content || occurrenceStatus?has_content || recordNumber?has_content ||
eventID?has_content || fieldNumber?has_content>
  <@common.article id="occurrence" title="Occurrence details">
  <div class="left">

      <#-- Show event date, partial event date, or verbatim event date in that order of priority + the recorder -->
        <#if eventDate?has_content || partialGatheringDate?has_content || recordedBy?has_content || verbatimEventDate?has_content >
            <h3>Recorded</h3>
          <#if eventDate?has_content>
              <p>${eventDate!?datetime?string.medium}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
          <#elseif partialGatheringDate?has_content >
              <p>${partialGatheringDate}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
          <#elseif verbatimEventDate?has_content >
              <p>${verbatimEventDate}<#if recordedBy?has_content>&nbsp;by&nbsp;${recordedBy}</#if></p>
          <#else>
              <p>By&nbsp;${recordedBy}</p>
          </#if>
        </#if>

        <@kv header="Associated Occurrences" value=associatedOccurrences />
        <@kv header="Associated Sequences" value=associatedSequences />
        <@kv header="Associated References" value=associatedReferences />
        <@kv header="Associated Taxa" value=associatedTaxa />
        <@kv header="Sampling Protocol" value=samplingProtocol />
        <@kv header="Sampling Effort" value=samplingEffort />
        <@kv header="Field Notes" value=fieldNotes />

        <#-- Combine occurrence remarks and event remarks under the same heading Remarks -->
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

  <div class="right">
    <@kv header="Life Stage" value=occ.lifeStage!?string?lower_case?cap_first />
    <@kv header="Sex" value=occ.sex!?string?lower_case?cap_first />
    <@kv header="Establishment Means" value=occ.establishmentMeans!?string?lower_case?cap_first />
    <@kv header="Reproductive Condition" value=reproductiveCondition />
    <@kv header="Individual Count" value=occ.individualCount />
    <@kv header="Behavior" value=behavior />
    <@kv header="Occurrence Status" value=occurrenceStatus />
    <@kv header="Record Number" value=recordNumber />
    <@kv header="Event ID" value=eventID />
    <@kv header="Field Number" value=fieldNumber />
  </div>

  </@common.article>
</#if>


<#assign institutionCode = action.termValue('institutionCode')! />
<#assign institutionID = action.termValue('institutionID')! />
<#assign datasetID = action.termValue('datasetID')! />
<#assign datasetName = action.termValue('datasetName')! />
<#assign collectionCode = action.termValue('collectionCode')! />
<#assign collectionID = action.termValue('collectionID')! />
<#assign type =  action.termValue('type')! />
<#assign ownerInstitutionCode =  action.termValue('ownerInstitutionCode')! />
<#assign disposition =  action.termValue('disposition')! />
<#assign preparations =  action.termValue('preparations')! />
<#assign dataGeneralizations =  action.termValue('dataGeneralizations')! />
<#assign informationWithheld =  action.termValue('informationWithheld')! />
<#assign dynamicProperties =  action.termValue('dynamicProperties')! />
<#assign occurrenceID =  action.termValue('occurrenceID')! />
<#assign catalogNumber =  action.termValue('catalogNumber')! />
<#assign otherCatalogNumbers =  action.termValue('otherCatalogNumbers')! />
<#assign language =  action.termValue('language')! />

<#-- Source block consists of various terms/fields. At least 1 has to be present for block to appear -->
<#if occ.basisOfRecord?has_content || occ.identifiers?has_content || institutionCode?has_content ||
institutionID?has_content || datasetID?has_content || datasetName?has_content || collectionCode?has_content ||
collectionID?has_content || type?has_content || ownerInstitutionCode?has_content || disposition?has_content ||
preparations?has_content || dataGeneralizations?has_content || informationWithheld?has_content ||
dynamicProperties?has_content || occurrenceID?has_content || catalogNumber?has_content ||
otherCatalogNumbers?has_content || language?has_content>
  <@common.article id="source" title="Source details">
  <div class="left">
      <h3>Data publisher</h3>
      <p><a href="<@s.url value='/publisher/${publisher.key}'/>" title="">${publisher.title}</a></p>
      <#if occ.references??>
        <p><a target="_blank" href="${occ.references}">Record details on publisher site</a></p>
      </#if>

  <#-- institution code and institution ID on same line -->
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

    <@kv header="Owner Institution Code" value=ownerInstitutionCode />

      <h3>Dataset</h3>
      <p><a href="<@s.url value='/dataset/${dataset.key}'/>" title="">${dataset.title}</a></p>

  <#-- dataset and dataset ID on same line -->
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

    <@kv header="Disposition" value=disposition />
    <@kv header="Preparations" value=preparations />
    <@kv header="Data Generalizations" value=dataGeneralizations />
    <@kv header="Information Withheld" value=informationWithheld />
    <@kv header="Dynamic Properties" value=dynamicProperties />
  </div>

  <div class="right">

    <@kv header="Occurrence ID" value=occurrenceID />

      <h3>GBIF ID</h3>
      <p>${id?c}</p>

    <@kv header="Catalog number" value=catalogNumber />
    <@kv header="Other Catalog numbers" value=otherCatalogNumbers />

    <#list occ.identifiers as i>
        <h3>${i.type}</h3>
        <p>${i.identifier}</p>
    </#list>

    <@kv header="Language" value=language />
  </div>

  </@common.article>
</#if>

<#assign earliestEonOrLowestEonothem = action.termValue('earliestEonOrLowestEonothem')! />
<#assign latestEonOrHighestEonothem = action.termValue('latestEonOrHighestEonothem')! />
<#assign earliestEraOrLowestErathem = action.termValue('earliestEraOrLowestErathem')! />
<#assign latestEraOrHighestErathem = action.termValue('latestEraOrHighestErathem')! />
<#assign earliestPeriodOrLowestSystem = action.termValue('earliestPeriodOrLowestSystem')! />
<#assign latestPeriodOrHighestSystem = action.termValue('latestPeriodOrHighestSystem')! />
<#assign earliestEpochOrLowestSeries = action.termValue('earliestEpochOrLowestSeries')! />
<#assign latestEpochOrHighestSeries = action.termValue('latestEpochOrHighestSeries')! />
<#assign earliestAgeOrLowestStage = action.termValue('earliestAgeOrLowestStage')! />
<#assign latestAgeOrHighestStage = action.termValue('latestAgeOrHighestStage')! />
<#assign lowestBiostratigraphicZone = action.termValue('lowestBiostratigraphicZone')! />
<#assign highestBiostratigraphicZone = action.termValue('highestBiostratigraphicZone')! />
<#assign bed = action.termValue('bed')! />
<#assign formation = action.termValue('formation')! />
<#assign group = action.termValue('group')! />
<#assign member = action.termValue('member')! />
<#assign geologicalContextID = action.termValue('geologicalContextID')! />
<#assign lithostratigraphicTerms = action.termValue('lithostratigraphicTerms')! />

<#-- Geology block consists of various terms/fields. At least 1 has to be present for block to appear -->
<#if earliestEonOrLowestEonothem?has_content ||
latestEonOrHighestEonothem?has_content || earliestEraOrLowestErathem?has_content ||
latestEraOrHighestErathem?has_content || earliestPeriodOrLowestSystem?has_content ||
latestPeriodOrHighestSystem?has_content || earliestEpochOrLowestSeries?has_content ||
latestEpochOrHighestSeries?has_content || earliestAgeOrLowestStage?has_content ||
latestAgeOrHighestStage?has_content || lowestBiostratigraphicZone?has_content ||
highestBiostratigraphicZone?has_content || bed?has_content || formation?has_content || group?has_content ||
member?has_content || geologicalContextID?has_content || lithostratigraphicTerms?has_content>
<#-- show additional geological context group verbatim terms, excluding those terms (usually interpreted terms) already shown -->
  <@common.article id="geology" title="Geological context">
  <div class="left">

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

    <@kv header="Bed" value=bed />
    <@kv header="Formation" value=formation />
    <@kv header="Group" value=group />
    <@kv header="Member" value=member />
  </div>

  <div class="right">
    <@kv header="Geological Context ID" value=geologicalContextID />
      <@kv header="Lithostratigraphic Terms" value=lithostratigraphicTerms />
  </div>

  </@common.article>
</#if>

<#if occ.media?has_content>
  <@common.article id="media" title="Associated media">
  <div class="fullwidth">
    <#list occ.media as m>
      <#assign link = m.references!m.identifier />
      <#if link?has_content>
       <#assign created>${m.creator!}<#if m.created?has_content><#if m.creator?has_content>, </#if>${m.created?date}</#if></#assign>
       <div class="col">
        <h3><@s.text name="enum.mediatype.${m.type!'NULL'}"/> <#if m.format?has_content><span class="small">[${m.format}]</span></#if></h3>
        <dl>
          <@common.definition title="Title" value=m.title! />
          <@common.definition title="Media file" value=m.identifier! />
          <@common.definition title="Link" value=m.references! />
          <@common.definition title="Description" value=m.description! />
          <@common.definition title="Source" value=m.source! />
          <@common.definition title="Audience" value=m.audience! />
          <@common.definition title="Creator" value=created! />
          <@common.definition title="Contributor" value=m.contributor! />
          <@common.definition title="Publisher" value=m.publisher! />
          <@common.definition title="Rights Holder" value=m.rightsHolder! />
          <@common.definition title="License" value=m.license! />
        </dl>
       </div>
      </#if>
    </#list>
  </div>
  </@common.article>
</#if>

<#--
<#if occ.facts?has_content>
  <@common.article id="measurementOrFact" title="Measurement or fact">
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
  </@common.article>
</#if>
-->

<#--<#if (occ.relations?size > 0) >
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

<#assign rights = action.termValue('rights')!"" />
<#assign bibliographicCitation = action.termValue('bibliographicCitation')!"" />
<#assign accessRights = action.termValue('accessRights')!"" />
<#assign rightsHolder = action.termValue('rightsHolder')!"" />
<@citationArticle bibliographicCitation=bibliographicCitation rights=rights accessRights=accessRights rightsHolder=rightsHolder dataset=dataset publisher=publisher />

<@common.notice title="Record history">
  <#if occ.lastInterpreted?has_content>
  <p>
    This record was last modified in GBIF on ${occ.lastInterpreted?date?string.medium}.
    <#if occ.lastCrawled?has_content>
      The source was last visited by GBIF on ${occ.lastCrawled?date?string.medium}.
    </#if>
    <#if occ.modified??>
      It was last updated according to the publisher on ${occ.modified?date?string.medium}.
    </#if>
  </p>
  </#if>
  <p>
    A record will be modified by GBIF when either the source record has been changed by the publisher, or improvements in the GBIF processing warrant an update.
    There may be more details available about this occurrence in the <a href="<@s.url value='/occurrence/${id?c}/verbatim'/>">verbatim version</a> of the record.
  </p>
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
