<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>${dataset.title!"???"} - Dataset detail</title>
  <content tag="extra_scripts">
    <#if renderMaps>
      <!-- Subscribe to changes on the map and configure our search URL-->
      <script type="text/javascript" src="${cfg.tileServerBaseUrl!}/map-events.js"></script>
      <script type="text/javascript">
        new GBIFMapListener().subscribe(function(id, searchUrl) {
          $("#geoOccurrenceSearch").attr("href", "<@s.url value='/occurrence/search'/>?" +  searchUrl.replace("DATASET", "DATASET_KEY"));
        });
          
        // create an array of the bounding boxes from the geographic coverages
        // we ignore anything that is global as that tells us very little
        var bboxes = [
          <#list dataset.geographicCoverages as geo>
            <#if geo.boundingBox?has_content && (!geo.boundingBox.isGlobalCoverage())>
              [${geo.boundingBox.minLatitude?c},${geo.boundingBox.maxLatitude?c},${geo.boundingBox.minLongitude?c},${geo.boundingBox.maxLongitude?c}],
            </#if>
          </#list>
        ];
        
        // paint the bounding box once the iframe is loaded
        // This will only work when deployed in the same domain, but this is considered a good old hack for this isolated case 
        var mapframe = document.getElementById('mapframe');
        mapframe.onload = function() {
          mapframe.contentWindow.addBboxes(bboxes);
        };
      </script>
    </#if>

    <#-- setup taxonomic browser ? -->
    <#if dataset.type! == "CHECKLIST">
      <#include "/WEB-INF/inc/taxonomic_browser.ftl">
      <script type="text/javascript">
        $(function() {
          $("#taxonomicBrowser").taxonomicExplorer("${id}");
        });
      </script>
    </#if>

    <style type="text/css">
        #primaryContacts .contact {
          width: 199px;
          float: left;
        }
        article .right ul.notes {
          padding-left: 0px;
        }
    </style>
  </content>
</head>
<body>

<#assign tab="info"/>
<#include "/WEB-INF/pages/dataset/inc/infoband.ftl">

<#-- Has this dataset been flagged as deleted? In other words, is the deleted timestamp not null? -->
<#if dataset.deleted?has_content>
  <@common.notice title="Dataset has been deleted">
    <p>You are viewing the metadata for a dataset that was deleted on ${dataset.deleted?date}.</p>
  </@common.notice>
</#if>

<#-- SUMMARY -->
<@common.article id="summary" title="Summary">
<div class="left">
  <h3>Full Title</h3>
  <p>${dataset.title}</p>

  <#if dataset.description?has_content>
    <h3>Description</h3>
    <p>${dataset.description}</p>
  </#if>
<#-- purpose doesn't exist yet -->
  <#if dataset.purpose?has_content>
    <h3>Purpose</h3>
    <p>${dataset.purpose}</p>
  </#if>
<#-- additionalInformation doesn't exist yet -->
  <#if dataset.additionalInfo?has_content>
    <h3>Additional Information</h3>
    <p>${dataset.additionalInfo}</p>
  </#if>

  <#if dataset.temporalCoverages?has_content>
    <h3>Temporal coverages</h3>
    <#list dataset.temporalCoverages as cov>
      <p>
      <#if cov.type?has_content && cov.period?has_content>
        <@s.text name="enum.verbatimtimeperiodtype.${cov.type}"/>: ${cov.period}
      <#elseif cov.date?has_content>
        Single date: ${cov.date?date}
      <#elseif cov.start?has_content && cov.end?has_content>
        Date range: ${cov.start?date} - ${cov.end?date}
      </#if>
      </p>
    </#list>
  </#if>

  <#if dataset.metadataLanguage?has_content>
    <h3>Language of Metadata</h3>
    <p>${dataset.metadataLanguage}</p>
  </#if>

  <#if dataset.dataLanguage?has_content>
    <h3>Language of Data</h3>
    <@common.enumParagraph dataset.dataLanguage />
  </#if>

  <#if (preferredContacts?size>0) >
    <div id="primaryContacts">
      <#list preferredContacts as c>
        <@common.contact con=c />
      </#list>
    </div>
  </#if>

  <#-- Display the full keywords / tags if they were too many to show in the title (see infoband.ftl) -->
  <#if keywordsTruncatedInTitle>
    <a id="keywords"/>
    <h3>Keywords and tags</h3>
    <p>    
    <#list keywords as k>
      <a href="<@s.url value='/dataset/search?q=${k}'/>">${k}</a>,&nbsp;  
    </#list>
    </p>
  </#if>
</div>

<div class="right">
  <#assign max_show_length = 30>

<#assign type="dataset"/>

  <#if dataset.logoUrl?has_content>
    <div class="logo_holder">
      <img src="" data-load="<@s.url value='${dataset.logoUrl}'/>" />
    </div>
  </#if>

  <#if parentDataset??>
    <h3>Constituent of</h3>
    <p><a href="<@s.url value='/dataset/${parentDataset.key}'/>" title="${parentDataset.title!"Unknown"}">${parentDataset.title!"Unknown"}</a></p>
  </#if>

  <#if publisher??>
    <h3>Published by</h3>
    <p><a href="<@s.url value='/publisher/${publisher.key}'/>"
          title="${publisher.title!"Unknown"}">${publisher.title!"Unknown"}</a></p>
  </#if>

  <#if dataset.pubDate?has_content>
    <h3>Publication Date</h3>
    <p>${(dataset.pubDate?date)}</p>
  </#if>

  <h3>Registration Date</h3>
  <p>${dataset.created?date}</p>

  <!-- Only show host if it's different from owning publisher -->
  <#if host.key! != publisher.key!>
    <h3>Hosted by</h3>
    <p><a href="<@s.url value='/publisher/${host.key}'/>"
          title="${host.title!"Unknown"}">${host.title!"Unknown"}</a></p>
  </#if>

  <h3>Served by</h3>
  <p><a href="<@s.url value='/installation/${installation.key}'/>"
        title="${installation.title!"Unknown"}">${installation.title!"Unknown"}</a></p>

  <!-- Could be an external dataset, with an owning org, but no endorsing node since it's not in GBIF Network -->
  <#if (publisher.endorsingNode)?has_content>
    <h3>Endorsed by</h3>
    <p><a href="<@s.url value='/node/${publisher.endorsingNode.key}'/>"
          title="${publisher.endorsingNode.title!"Unknown"}">${publisher.endorsingNode.title!"Unknown"}</a>
    </p>
  </#if>

  <#if networks?has_content>
    <h3>Networks</h3>
    <ul>
    <#list networks as n>
      <li>
        <a href="<@s.url value='/network/${n.key}'/>" title="${n.title}">${n.title}</a>
      </li>
    </#list>
    </ul>
  </#if>

  <#if dataset.homepage?has_content || links?has_content>
    <p>
    <h3>Links</h3>
    <ul>
      <#if dataset.homepage?has_content>
      <li><a href="<@s.url value='${dataset.homepage}' target='_blank'/>" title="Dataset homepage">Dataset homepage</a></li>
      </#if>
      <#list links as p>
        <#if p.url?has_content>
          <li>
            <a href="<@s.url value='${p.url}'/>" title="<@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/>"><@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/></a>
          </li>
        </#if>
      </#list>
    </ul>
    </p>
  </#if>

  <!-- Ideally the alt. identifier has a type which is displayed as a link to the identifier. Otherwise, a trimmed version is displayed. In both cases, a popup appears to display the full identifier. -->
  <#if (dataset.identifiers?size>0)>
   <p>
    <h3>Alternative Identifiers</h3>
    <ul class="notes">
      <#list dataset.identifiers as idt>
      <#if idt.identifier?has_content>
        <li>
          <#if idt.type?has_content && idt.type != "UNKNOWN">
            <#-- if there is a type, there is the possibility of an interpreted link -->
            <#if idt.identifierLink?has_content>
              <a href="${idt.identifierLink}"><@s.text name="enum.identifiertype.${idt.type}"/></a>
            <#else>
              <a href="#"><@s.text name="enum.identifiertype.${idt.type}"/></a>
            </#if>
          <#else>
            Alternative Identifier
          </#if>
          <span class="note">${common.limit(idt.identifierLink!idt.identifier,max_show_length)}</span>
        </li>
      </#if>
      </#list>
    </ul>
    </p>
  </#if>
  

  <#-- DATA DESCRIPTIONS -->
  <#-- By urgent request, we do not show links to the UK NBN data files -->
  <#if (dataset.dataDescriptions?has_content || dataLinks?has_content) && publisher.key! != common.uknbnOrganizationKey>
    <p>
    <h3>External Data</h3>
    <ul class="notes">
    <#list dataLinks as p>
      <#if p.url?has_content>
        <li>
          <a href="${p.url}" title="<@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/>"><@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/></a>
        </li>
      </#if>
    </#list>
    <#-- URL, name, charset, and format are all required by the GBIF Metadata Schema, but not required by the GBIF API -->
    <#-- The URL must be present here, otherwise there is nothing to display in the list -->
    <#-- This restriction was added Aug 20 2013 in order to fix http://dev.gbif.org/issues/browse/PF-75 -->
    <#list dataset.dataDescriptions as dd>
      <#if dd.url?has_content>
        <li>
          <a href="${dd.url}">${dd.name!dd.url}</a>
          <#if dd.format?has_content || dd.charset?has_content>
            <span class="note">${dd.format!} ${dd.formatVersion!}<#if dd.format?has_content && dd.charset?has_content>&middot;</#if> ${dd.charset!}</span>
          </#if>
        </li>
      </#if>
    </#list>
    </ul>
    </p>
  </#if>

  <p>  
  <h3>Metadata Documents</h3>
  <ul>
    <#list metaLinks as p>
      <#if p.url?has_content>
        <li>
          <a href="${p.url}" title="<@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/>">Original document (<@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/>)</a>
          <#if p.type=="EML">
            <@common.popup message="This is a link to the original metadata document. The metadata may be different from the version that is displayed if it has been updated since the time the dataset was last indexed." title="Note"/>
          </#if>
        </li>
        <li class="download verify">
          <a href="${cfg.wsReg}dataset/${dataset.key}/document">Cached copy (<@s.text name='enum.endpointtype.${p.type!"UNKNOWN"}'/>)</a>
          <@common.popup message="The cached copy of the original serves to distinguish cases where the source of content on this page might be confusing, or where the original is not accessible" title="Note"/>
        </li>
        
      </#if>
    </#list>
    <#-- we verify asynchroneously via app.js all links with class=verify and hide the list element in case of errors or 404 -->
    
    
    <li class="download">
      <a href="${cfg.wsReg}dataset/${dataset.key}/document">GBIF annotated version (EML)</a>
      <@common.popup message="The GBIF annotated version is created based on available content according to the <a href='http://www.gbif.org/orc/?doc_id=2820'>GBIF Metadata Profile</a>. Please note that it might not be as rich as the original version and the document will vary over time as content is indexed, and algorithms for producing the document are improved" title="Note"/>
    </li>
  </ul>
  </p>

</div>

</@common.article>


<#-- TAXONOMIC COVERAGE -->
<#if organizedCoverages?has_content >
  <@common.article id="taxonomic_coverage" title="Taxonomic Coverage">
  <div class="fullwidth">
    <div class="scrollable">
      <#list organizedCoverages as ocs>
        <#if ocs.description?has_content>
            <p>${ocs.description}</p>
        </#if>
        <dl>
        <#list ocs.coverages as oc>
            <dt>${oc.rank}</dt>
            <dd>
              <#list oc.displayableNames as dis>
                <a href="<@s.url value='/species/search?q=${dis.scientificName!dis.commonName}'/><#if (dis.rank.interpreted)?has_content>&rank=${dis.rank.interpreted!}</#if>">${dis.displayName}</a><#if dis_has_next>, </#if>
              </#list>
            </dd>
        </#list>
        </dl>
      </#list>
    </div>
  </div>
</@common.article>
</#if>

<#if dataset.type! == "CHECKLIST" && metrics?? && metrics.usagesCount gt 0>
<@common.article id="taxonomy" title="Browse Classification" class="taxonomies">
<div class="fullwidth">
  <div id="taxonomicBrowser"></div>
</div>
</@common.article>
</#if>

<#-- MAPS -->
<#if renderMaps>
  <@common.article titleRight='${numGeoreferencedOccurrences!0} Georeferenced data' class="map">
    <div id="map" class="map">
      <iframe id="mapframe" name="mapframe" src="${cfg.tileServerBaseUrl!}/index.html?type=DATASET&key=${id!}&style=classic&resolution=${action.getMapResolution(numGeoreferencedOccurrences)}" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>
    </div>
    <div class="right">
       <div class="inner">
         <h3>View records</h3>
         <p>
           <a href="<@s.url value='/occurrence/search?datasetKey=${id!}&GEOREFERENCED=true&SPATIAL_ISSUES=false'/>">All records</a>
           |
           <#-- Note this is intercepted in the map.js to append the bounding box -->
           <a href="<@s.url value='/occurrence/search?datasetKey=${id!}'/>" id='geoOccurrenceSearch'>In viewable area</a></li>
         </p>
         <#-- Truncate long coverages, and display with a more link -->
         <#assign coverage><#list dataset.geographicCoverages as geo>${geo.description!}</#list></#assign>
         <#if coverage?has_content>
           <h3>Description</h3>
           <#assign coverageUrl><@s.url value='/dataset/${id!}/geographicCoverage'/></#assign>
           <p><@common.limitWithLink text=coverage max=200 link=coverageUrl/></p>
         </#if>
         <h3>About</h3>
        <p>
           <@common.explanation message="The map illustrates all known geographic information about the dataset.
           This includes any documented geographic coverage available through dataset metadata, and a data layer from any indexed data.
           The data layer can be customized with the controls above." label="What does this map show?" title="Help"/>
         </p>
       </div>
    </div>
  </@common.article>
</#if>

<#if dataset.geographicCoverages?has_content>
<article>
  <header></header>
  <div class="content">
    <div class="header">
      <div class="left"><h2>Geographic Coverage</h2></div>
    </div>
    <div class="fullwidth">
      <div class="scrollable">
        <#list dataset.geographicCoverages as geo>
          <p>${geo.description!}</p>
        </#list>
      </div>
    </div>
  </div>
  <footer></footer>
</article>
</#if>

<#-- PROJECT -->
<#if dataset.project?has_content || (otherContacts?size>0) >
<#assign rtitle><span class="showAllContacts small">show all</span></#assign>
<@common.article id="project" title='${(dataset.project.title)!"Project"}' titleRight=rtitle>
<div class="left">
  <#if dataset.project?has_content>
    <#assign proj=dataset.project />
    <#if proj.studyAreaDescription?has_content>
      <h3>Study area description</h3>
      <p>${proj.studyAreaDescription}</p>
    </#if>

    <#if proj.designDescription?has_content>
      <h3>Design description</h3>
      <p>${proj.designDescription}</p>
    </#if>

    <#if proj.funding?has_content>
      <h3>Funding</h3>
      <p>${proj.funding}</p>
    </#if>

    <#if proj.contacts?has_content>
      <h3>Project Personnel</h3>
      <#list proj.contacts as per>
        <@common.contact con=per />
        <#if per_has_next && per_index==3>
          <div class="more"> <a href="<@s.url value='/dataset/${dataset.key}/contacts'/>">more</a> </div>
          <#break />
        </#if>
      </#list>
    </#if>
  </#if>
</div>

<div class="right">
  <#if (otherContacts?size>0) >
    <h3>Associated parties</h3>
    <#list otherContacts as ap>
      <@common.contact con=ap />
      <#if ap_has_next && ap_index==2>
        <div class="more"> <a href="<@s.url value='/dataset/${dataset.key}/contacts'/>">more</a> </div>
        <#break />
      </#if>
    </#list>
  </#if>
</div>
</@common.article>
</#if>

<#-- METHODS -->
<#if dataset.samplingDescription?has_content>
<@common.article id="methods" title="Methodology">
  <#assign sd=dataset.samplingDescription />
<div class="left">

  <#if sd.studyExtent?has_content>
    <h3>Study extent</h3>
    <p>${sd.studyExtent}</p>
  </#if>

  <#if sd.sampling?has_content>
    <h3>Sampling description</h3>
    <p>${sd.sampling}</p>
  </#if>

  <#if sd.qualityControl?has_content>
    <h3>Quality control</h3>
    <p>${sd.qualityControl}</p>
  </#if>

  <#if sd.methodSteps?has_content>
    <h3>Method Steps</h3>
    <ol>
      <#list sd.methodSteps as step>
        <#if step?has_content>
         <li>${step}</li>
        </#if>
      </#list>
    </ol>
  </#if>
</div>

<div class="right">
  <#if dataset.collections?has_content>
    <#list dataset.collections as col>
      <#if col.collectionName?has_content>
        <h3>Collection name</h3>
        <p>${col.collectionName}</p>
      </#if>

      <#if col.collectionIdentifier?has_content>
        <h3>Collection Identifier</h3>
        <p>${col.collectionIdentifier}</p>
      </#if>

      <#if col.parentCollectionIdentifier?has_content>
        <h3>Parent Collection Identifier</h3>
        <p>${col.parentCollectionIdentifier}</p>
      </#if>

      <#if col.specimenPreservationMethod?has_content>
        <h3>Specimen Preservation method</h3>
        <p><@s.text name="enum.preservationmethodtype.${col.specimenPreservationMethod}"/></a></p>
      </#if>

      <#if col.curatorialUnits?has_content >
        <h3>Curational Units</h3>
        <ul>
          <#list col.curatorialUnits as unit>
            <#if unit.typeVerbatim?has_content && unit.lower!=0 && unit.upper!=0>
              <li>${unit.lower} - ${unit.upper} ${unit.typeVerbatim?lower_case}</li>
            <#elseif unit.typeVerbatim?has_content && unit.count!=0>
              <li>${unit.count} <#if unit.deviation?has_content> ± ${unit.deviation}</#if> ${unit.typeVerbatim?lower_case}</li>
            </#if>
          </#list>
        </ul>
      </#if>
    </#list>
  </#if>
</div>
</@common.article>
</#if>

<#-- CITATIONS -->
<#if dataset.bibliographicCitations?has_content >
<@common.article id="references" title="References">
<div class="fullwidth">
  <div class="scrollable">
    <#if (dataset.bibliographicCitations?size>0)>
      <#list dataset.bibliographicCitations as ref>
        <p>
          <@common.citation ref/>
        </p>
      </#list>
    </#if>
  </div>
</div>
</@common.article>
</#if>

<#if (constituents.results)?has_content>
<@common.article id="datasets" title="Constituent Datasets">
  <div class="fullwidth">
      <ul class="notes">
        <#list datasets as cw>
          <@common.datasetListItem title=cw.obj.title key=cw.obj.key type=cw.obj.type modified=cw.obj.modified count=cw.count geoCount=cw.geoCount></@common.datasetListItem>
        </#list>
        <#if !constituents.isEndOfRecords()>
            <li class="more">
                <a href="<@s.url value='/dataset/${member.key}/constituents'/>">more</a>
            </li>
        </#if>
      </ul>
  </div>
</@common.article>
</#if>

<#-- LEGAL -->
<@common.citationArticle rights=dataset.rights!"" dataset=dataset publisher=publisher />

</body>
</html>
