<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>GBIF Occurrence API</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
</head>

<#assign tab="occurrence"/>
<#include "/WEB-INF/pages/developer/inc/tabs.ftl" />

<body class="api">


<@api.introArticle>
<div class="left">
     <p>
       This API works against the GBIF Occurrence Store, which handles occurrence records and makes them available through the web service and download files.
       In addition we also provide a <a href="<@s.url value='/developer/maps'/>">Map API</a> that offers spatial services.
    </p>
    <p>
        Internally we use a Java web service client for the consumption of these HTTP-based, RESTful web services. It may
        be of interest to those coding against the API, and can be found in the <a href="https://github.com/gbif/occurrence/tree/master/occurrence-ws-client" target="_blank">occurrence-ws-client</a>.
    </p>
</div>
<div class="right">
    <ul>
        <li><a href="#occurrence">Occurrences</a></li>
        <li><a href="#search">Search Occurrences</a></li>
        <li><a href="#download">Occurrence Downloads</a></li>
        <li><a href="#predicates">Occurrence Download Filters</a></li>
        <li><a href="#metrics">Occurrence Metrics</a></li>
        <li><a href="#inventories">Occurrence Inventories</a></li>
    </ul>
</div>
</@api.introArticle>



<#-- define some often occurring defaults -->
<#macro trowO url method="GET" resp="Occurrence" respLink="" >
  <@api.trow url="/occurrence"+url httpMethod=method resp=resp respLink=respLink authRequired="" showParams=false paging=""><#nested /></@api.trow>
</#macro>

<#macro trowS url resp="Occurrence" respLink="" paging=false params=[] method="GET">
  <@api.trow url="/occurrence/search"+url httpMethod="GET" resp=resp respLink=respLink paging=paging params=params authRequired="" httpMethod=method><#nested /></@api.trow>
</#macro>

<#macro trowD url resp="" method="GET" respLink="" paging=false authRequired=false>
  <@api.trow url="/occurrence/download"+url resp=resp httpMethod=method respLink=respLink paging=paging authRequired=authRequired showParams=false><#nested /></@api.trow>
</#macro>

<#macro trowM url resp="" respLink="" params=[]>
  <@api.trow url=url resp=resp httpMethod="GET" respLink=respLink paging="" authRequired="" params=params><#nested /></@api.trow>
</#macro>



<@api.article id="occurrence" title="Occurrences">
<p>This API provides services related to the retrieval of single occurrence records.</p>

  <@api.apiTable auth=false paging=false params=false>
    <@trowO url="/{key}" respLink="occurrence/252408386">Gets details for a single, interpreted occurrence</@trowO>
    <@trowO url="/{key}/fragment" respLink="occurrence/252408386/fragment">Get a single occurrence fragment in its raw form (xml or json)</@trowO>
    <@trowO url="/{key}/verbatim" resp="VerbatimOccurrence" respLink="occurrence/252408386/verbatim">Gets the verbatim occurrence record without any interpretation</@trowO>
  </@api.apiTable>

</@api.article>



<@api.article id="search" title="Searching">
<p>This API provides services for searching occurrence records that have been indexed by GBIF.
  In order to retrieve all results for a given search filter you need to issue individual requests for each page,
  which is limited to a maximum size of 300 records per page.

  Note that for technical reasons we also have a hard limit for any query of 200.000 records.
  You will get an error if the offset + limit exceeds 200.000.
  To retrieve all records beyond 200.000 you should use our asynchronous <a href="#download">download service</a> instead.
</p>

  <@api.apiTable auth=false>
    <@trowS url="" respLink="occurrence/search?taxonKey=1"  paging=true params=["datasetKey","year","month","eventDate","lastInterpreted","decimalLatitude","decimalLongitude","country","continent","publishingCountry","elevation","depth","institutionCode", "collectionCode", "catalogNumber","recordedBy","recordNumber","basisOfRecord","taxonKey","scientificName","hasCoordinate","geometry","spatialIssues", "issue", "mediaType"]>Full search across all occurrences.
    Results are ordered by relevance.</@trowS>
    <@trowS url="/catalogNumber" respLink="occurrence/search/catalogNumber?q=122&limit=5" params=["q","limit"]>Search that returns matching catalog numbers.
    Results are ordered by relevance.</@trowS>
    <@trowS url="/collectionCode" respLink="occurrence/search/collectionCode?q=12&limit=5" params=["q","limit"]>Search that returns matching collection codes.
    Results are ordered by relevance.</@trowS>
    <@trowS url="/recordedBy" respLink="occurrence/search/recordedBy?q=juan&limit=5" params=["q","limit"]>Search that returns matching collector names.
    Results are ordered by relevance.</@trowS>
    <@trowS url="/institutionCode" respLink="occurrence/search/institutionCode?q=GB&limit=5" params=["q","limit"]>Search that returns matching institution codes.
    Results are ordered by relevance.</@trowS>
  </@api.apiTable>
</@api.article>



<@api.article id="download" title="Occurrence Downloads">
<p>This API provides services to download occurrence records and retrieve information about those downloads.</p>
<p>Occurrence downloads are created asynchronously - the user requests a download and, once complete, is sent and email with a link to the resulting file.</p>
<p>Internally we use a Java web service client for the consumption of these HTTP-based, RESTful web services. It may
  be of interest to those coding against the API, and can be found in the <a href="https://github.com/gbif/occurrence/tree/master/occurrence-ws-client" target="_blank">occurrence-download-ws-client</a>.
</p>

  <@api.apiTable params=false>
    <@trowD url="/request" resp="Download key" method="POST" authRequired=true>Starts the process of creating a download file. See the <a href="#predicates">predicates</a> section to consult the requests accepted by this service.</@trowD>
    <@trowD url="/request/{key}" resp="Download file" respLink="occurrence/download/request/0000251-150304104939900" method="GET" authRequired=false>Retrieves the download file if it is available.</@trowD>
    <@trowD url="/request/{key}" method="DELETE" authRequired=true>Cancels the download process.</@trowD>
    <@trowD url="" method="GET" resp="Download Page" authRequired=true paging=true>Lists all the downloads. This operation can be executed by the role ADMIN only.</@trowD>
    <@trowD url="/{key}" resp="Download" respLink="occurrence/download/0000251-150304104939900" method="GET">Retrieves the occurrence download metadata by its unique key.</@trowD>
    <@trowD url="/{key}" method="PUT" authRequired=true>Updates the status of an existing occurrence download. This operation can be executed by the role ADMIN only.</@trowD>
    <@trowD url="/{key}" method="POST" authRequired=true>Creates the metadata about an occurrence download. This operation can be executed by the role ADMIN only.</@trowD>
    <@trowD url="/{key}/datasets" method="GET" authRequired=false resp="Datasets" respLink="occurrence/download/0000251-150304104939900/datasets">Lists all the datasets of an occurrence download.</@trowD>
    <@trowD url="/user/{user}" method="GET" resp="Download Page" authRequired=true paging=true>Lists the downloads created by a user. Only role ADMIN can list downloads of other users.</@trowD>
    <@trowD url="occurrence/download/dataset/{datasetKey}" method="GET" resp="Downloads list" authRequired=true paging=true respLink="occurrence/download/dataset/7f2edc10-f762-11e1-a439-00145eb45e9a">Lists the downloads activity of dataset.</@trowD>
  </@api.apiTable>
</@api.article>


<@api.article id="metrics" title="Occurrence Metrics">
<p>This API provides services to retrieve various counts and metrics provided about occurrence records.
  The kind of counts that are currently supported are listed by the schema method, see below for details.
</p>

  <@api.apiTable auth=false paging=false>
    <@trowM url="/occurrence/count" resp="Count" respLink="occurrence/count">Returns occurrence counts for a predefined set of dimensions.
    The supported dimensions are enumerated in the <a href="${action.cfg.apiBaseUrl}/occurrence/count/schema" target="_blank">/occurrence/count/schema</a> service.
    An example for the count of georeferenced observations from Canada: <a href="${action.cfg.apiBaseUrl}/occurrence/count?country=CA&isGeoreferenced=true&basisOfRecord=OBSERVATION" target="_blank">/occurrence/count?country=CA&isGeoreferenced=true&basisOfRecord=OBSERVATION</a>.
    </@trowM>
    <@trowM url="/occurrence/count/schema" resp="Count" respLink="occurrence/count/schema">List the supported metrics by the service.</@trowM>
  </@api.apiTable>
</@api.article>


<@api.article id="inventories" title="Occurrence Inventories">
<p>This API provides services that list all distinct values together with their occurrence count for a given occurrence property.
  Only a few properties are supported, each with its own service to call.
</p>

  <@api.apiTable auth=false paging=false>
    <@trowM url="/occurrence/counts/basisOfRecord" resp="Counts" respLink="occurrence/counts/basisOfRecord">Lists occurrence counts by basis of record.</@trowM>
    <@trowM url="/occurrence/counts/year" resp="Counts" respLink="occurrence/counts/year?year=1981,2012" params=["year"]>Lists occurrence counts by year.</@trowM>
    <@trowM url="/occurrence/counts/datasets" resp="Counts" respLink="occurrence/counts/datasets?country=DE" params=["country","taxonKey"]>Lists occurrence counts for datasets that cover a given taxon or country.</@trowM>
    <@trowM url="/occurrence/counts/countries" resp="Counts" respLink="occurrence/counts/countries?publishingCountry=DE" params=["publishingCountry"]>Lists occurrence counts for all countries covered by the data published by the given country.</@trowM>
    <@trowM url="/occurrence/counts/publishingCountry" resp="Counts" respLink="occurrence/counts/publishingCountries?country=DE" params=["country"]>Lists occurrence counts for all countries that publish data about the given country.</@trowM>
  </@api.apiTable>
</@api.article>

<#assign params = {
  "datasetKey": "The occurrence dataset key (a uuid)",
  "year": "The 4 digit year. A year of 98 will be interpreted as AD 98. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "month": "The month of the year, starting with 1 for January. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "eventDate": "Occurrence date in ISO 8601 format: yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "lastInterpreted": "This date the record was last modified in GBIF, in ISO 8601 format: yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "decimalLatitude": "Latitude in decimals between -90 and 90 based on WGS 84.. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "decimalLongitude": "Longitude in decimals between -180 and 180 based on WGS 84.. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "country": "The 2-letter country code (as per <a href='http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm' target='_blank'>ISO-3166-1</a>) of the country in which the occurrence was recorded.",
  "continent": "Continent, as defined in our <a href='${api.apidocs}/vocabulary/Continent.html' target='_blank'>Continent enum</a>",
  "publishingCountry" : "The 2-letter country code (as per <a href='http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm' target='_blank'>ISO-3166-1</a>) of the owining organization's country.",
  "elevation": "Elevation (altitude) in meters above sea level. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "depth" : "Depth in meters relative to altitude. For example 10 meters below a lake surface with given altitude. Supports <a href='${baseUrl}/developer/summary#common'>range queries</a>.",
  "establishmentMeans": "EstablishmentMeans, as defined in our <a href='${api.apidocs}/vocabulary/EstablishmentMeans.html' target='_blank'>EstablishmentMeans enum</a>",
  "occurrenceID" : "A single globally unique identifier for the occurrence record as provided by the publisher.",
  "institutionCode" : "An identifier of any form assigned by the source to identify the institution the record belongs to. Not guaranteed to be unique.",
  "collectionCode": "An identifier of any form assigned by the source to identify the physical collection or digital dataset uniquely within the context of an institution.",
  "catalogNumber": "An identifier of any form assigned by the source within a physical collection or digital dataset for the record which may not be unique, but should be fairly unique in combination with the institution and collection code.",
  "recordedBy": "The person who recorded the occurrence.",
  "recordNumber": "An identifier given to the record at the time it was recorded in the field.",
  "basisOfRecord": "Basis of record, as defined in our <a href='${api.apidocs}/vocabulary/BasisOfRecord.html' target='_blank'>BasisOfRecord enum</a>",
  "taxonKey": "A taxon key from the GBIF backbone. All included and synonym taxa are included in the search, so a search for aves with taxonKey=212 (i.e. <a href='${action.cfg.apiBaseUrl}/occurrence/search?taxonKey=212' target='_blank'>/occurrence/search?taxonKey=212</a>) will match all birds, no matter which species.",
  "scientificName": "A scientific name from the <a href='${baseUrl}/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c'>GBIF backbone</a>. All included and synonym taxa are included in the search. Under the hood a call to the <a href='${baseUrl}/developer/species#searching'>species match service</a> is done first to retrieve a taxonKey. Only unique scientific names will return results, homonyms (many monomials) return nothing! Consider to use the taxonKey parameter instead and the species match service directly",
  "hasCoordinate": "Limits searches to occurrence records which contain a value in both latitude and longitude (i.e. hasCoordinate=true limits to occurrence records with coordinate values and hasCoordinate=false limits to occurrence records without coordinate values).",
  "geometry": "Searches for occurrences inside a polygon described in Well Known Text (WKT) format. Only POINT, LINESTRING, LINEARRING and POLYGON are accepted WKT types. For example, a shape written as POLYGON ((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1)) would be queried as is, i.e. <a href='${action.cfg.apiBaseUrl}/occurrence/search?geometry=POLYGON((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1))' target='_blank'>/occurrence/search?geometry=POLYGON((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1))</a>.",
  "spatialIssues": "Includes/excludes occurrence records which contain spatial issues (as determined in our record interpretation), i.e. spatialIssues=true returns only those records with spatial issues while spatialIssues=false includes only records without spatial issues. The absence of this parameter returns any record with or without spatial issues.",
  "issue": "A specific interpretation issue as defined in our <a href='${api.apidocs}/vocabulary/OccurrenceIssue.html' target='_blank'>OccurrenceIssue enum</a>",
  "mediaType": "The kind of multimedia associated with an occurrence as defined in our <a href='${api.apidocs}/vocabulary/MediaType.html' target='_blank'>MediaType enum</a>",
  "typeStatus": "Nomenclatural type (type status, typified scientific name, publication) applied to the subject.",
  "q" : "Simple search parameter. The value for this parameter can be a simple word or a phrase.",
  "limit": "The maximum number of results to return. This can't be greater than 300, any value greater is set to 300."
} />


<@api.paramArticle params=params apiName="Occurrence" />


<@common.article id="predicates" title="Occurrence Download Predicates">
<div class="fullwidth">
<p>A download predicate is an query expression to retrieve occurrence record downloads.</p>
<p>If you are interested in seeing some examples of how to use the Java API to build predicates, there are some <a href="https://github.com/gbif/occurrence/blob/master/occurrence-ws/src/test/java/org/gbif/occurrence/download/service/HiveQueryVisitorTest.java" target="_blank">test cases</a> that can be used as a reference.</p>
<p>The table below lists the supported predicates that can be combined to build download requests that can be POSTed to the <a href="#download">download API</a>.</p>

<table class='table table-bordered table-striped table-params'>
<thead>
<tr>
  <th width="10%" class='total'>Predicate</th>
  <th width="30%" class='total'>Description</th>
  <th width="60%">Example</th>
</tr>
</thead>

<tbody>
<tr>
  <td>equals</td>
  <td>equality comparison</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"equals",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"BASIS_OF_RECORD",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"value":"LITERATURE"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>and</td>
  <td>logical AND(conjuction)</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"and",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"predicates":
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[{"type":"equals","key":"HAS_GEOSPATIAL_ISSUE","value":"false"},<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"type":"equals","key":"TAXON_KEY","value":"2440447"}]<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>or</td>
  <td>logical OR(disjunction)</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"or",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"predicates":
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[{"type":"equals","key":"HAS_GEOSPATIAL_ISSUE","value":"false"},<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"type":"equals","key":"TAXON_KEY","value":"2440447"}]<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>lessThan</td>
  <td>is less than</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"lessThan",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"YEAR",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"value":"1900"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>lessThanOrEquals</td>
  <td>is less than or equals</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"lessThanOrEquals",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"ALTITUDE",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"value":"1000"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>greaterThan</td>
  <td>is greater than</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"greaterThan",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"YEAR",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"value":"1900"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>greaterThanOrEquals</td>
  <td>is greater than or equals</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"greaterThanOrEquals",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"ALTITUDE",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"value":"1000"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>in</td>
  <td>specify multiple values to be compared</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"in",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"CATALOG_NUMBER",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"values":["cat1","cat2","cat3"]<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>within</td>
  <td>geospatial predicate that checks if the coordinates are inside a POLYGON</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"within",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"geometry":"POLYGON((-130.78125 51.179342,<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-130.78125 22.593726,-62.578125 22.593726,<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-62.578125 51.179342,-130.78125 51.179342))"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>not</td>
  <td>logical negation</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"not",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"type":"equals",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"key":"CATALOG_NUMBER",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"value":"cat1"<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
<tr>
  <td>like</td>
  <td>search for a pattern</td>
  <td>
    <code>
      {<br/>
      &nbsp;&nbsp;"creator":"userName",<br/>
      &nbsp;&nbsp;"notification_address": ["userName@gbif.org"],<br/>
      &nbsp;&nbsp;"predicate":<br/>
      &nbsp;&nbsp;{<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"type":"like",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"key":"CATALOG_NUMBER",<br/>
      &nbsp;&nbsp;&nbsp;&nbsp;"value":"PAPS5-560%"<br/>
      &nbsp;&nbsp;}<br/>
      }<br/>
    </code>
  </td>
</tr>
</tbody>
</table>

</div>
</@common.article>
</body>
</html>
