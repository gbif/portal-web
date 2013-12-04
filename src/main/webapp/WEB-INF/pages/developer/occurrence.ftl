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
    </p>
    <p>
        Internally we use a Java web service client for the consumption of these HTTP-based, RESTful web services. It may
        be of interest to those coding against the API, and can be found in the <a href="http://code.google.com/p/gbif-occurrencestore/source/browse/occurrence/trunk/occurrence-ws-client/" target="_blank">occurrence-ws-client</a>.
    </p>
</div>
<div class="right">
    <ul>
        <li><a href="#occurrence">Occurrences</a></li>
        <li><a href="#search">Search Occurrences</a></li>
        <li><a href="#download">Occurrence Downloads</a></li>
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
    <@trowO url="/{key}" respLink="/occurrence/252408386">Gets details for a single, interpreted occurrence</@trowO>
    <@trowO url="/{key}/fragment" respLink="/occurrence/252408386/fragment">Not yet available. Will eventually get a single occurrence fragment in its raw form (xml or json) (expected November, 2013)</@trowO>
    <@trowO url="/{key}/verbatim" resp="VerbatimOccurrence" respLink="/occurrence/252408386/verbatim">Gets the verbatim (no interpretation) occurrence record</@trowO>
  </@api.apiTable>

</@api.article>



<@api.article id="search" title="Searching">
  <p>This API provides services for searching occurrence records that have been indexed by GBIF.</p>

  <@api.apiTable auth=false>
      <@trowS url="" respLink="/occurrence/search?taxonKey=1"  paging=true params=["datasetKey","year","month","latitude","longitude","country","publishingCountry","altitude","depth","institutionCode", "collectionCode", "catalogNumber","collectorName","basisOfRecord","taxonKey","georeferenced","geometry","spatialIssues"]>Full search across all occurrences.
      Results are ordered by relevance.</@trowS>
      <@trowS url="/catalog_number" respLink="/occurrence/search/catalog_number?q=122&limit=5" params=["q","limit"]>Search that returns matching catalog numbers.
      Results are ordered by relevance.</@trowS>
      <@trowS url="/collection_code" respLink="/occurrence/search/collection_code?q=12&limit=5" params=["q","limit"]>Search that returns matching collection codes.
      Results are ordered by relevance.</@trowS>
      <@trowS url="/collector_name" respLink="/occurrence/search/collector_name?q=juan&limit=5" params=["q","limit"]>Search that returns matching collector names.
      Results are ordered by relevance.</@trowS>
      <@trowS url="/institution_code" respLink="/occurrence/search/institution_code?q=GB&limit=5" params=["q","limit"]>Search that returns matching institution codes.
      Results are ordered by relevance.</@trowS>
    </@api.apiTable>
</@api.article>



<@api.article id="download" title="Occurrence Downloads">
  <p>This API provides services to download occurrence records and retrieve information about those downloads.</p>
  <p>Occurrence downloads are created asynchronously - the user requests a download and, once complete, is sent and email with a link to the resulting file.</p>
  <p>Internally we use a Java web service client for the consumption of these HTTP-based, RESTful web services. It may
    be of interest to those coding against the API, and can be found in the <a href="http://gbif-occurrencestore.googlecode.com/svn/occurrence-download/trunk/occurrence-download-ws-client/" target="_blank">occurrence-download-ws-client</a>.
  </p>

  <@api.apiTable params=false>
      <@trowD url="/request" resp="Download key" method="POST" authRequired=true>Starts the process of creating a download file. See the <a href="#predicates">predicates</a> section to consult the requests accepted by this service.</@trowD>
      <@trowD url="/request/{key}" resp="Download file" respLink="/occurrence/download/request/0000447-130906152512535" method="GET" authRequired=false>Retrieves the download file if it is available.</@trowD>
      <@trowD url="/request/{key}" method="DELETE" authRequired=true>Cancels the download process.</@trowD>
      <@trowD url="" method="GET" resp="Download Page" respLink="/occurrence/download" authRequired=true paging=true>Lists all the downloads. This operation can be executed by the role ADMIN only.</@trowD>
      <@trowD url="/{key}" resp="Download" respLink="/occurrence/download/0000447-130906152512535" method="GET">Retrieves the occurrence download metadata by its unique key.</@trowD>
      <@trowD url="/{key}" method="PUT" authRequired=true>Updates the status of an existing occurrence download. This operation can be executed by the role ADMIN only.</@trowD>
      <@trowD url="/{key}" method="POST" authRequired=true>Creates the metadata about an occurrence download. This operation can be executed by the role ADMIN only.</@trowD>
      <@trowD url="/user/{user}" method="GET" resp="Download Page" authRequired=true paging=true>Lists the downloads created by a user. Only role ADMIN can list downloads of other users.</@trowD>
    </@api.apiTable>
</@api.article>


<@api.article id="metrics" title="Occurrence Metrics">
  <p>This API provides services to retrieve various counts and metrics provided about occurrence records.</p>

  <@api.apiTable auth=false paging=false>
      <@trowM url="/count" resp="Count" respLink="/occurrence/count">Returns occurrence counts for a predefined set of dimensions.
        The supported dimensions are enumerated in the <a href="http://api.gbif.org/v0.9/occurrence/count/schema" target="_blank">/occurrence/count/schema</a> service.
        An example for the count of georeferenced observations from Canada: <a href="http://api.gbif.org/v0.9/occurrence/count?country=CANADA&georeferenced=true&basisOfRecord=OBSERVATION" target="_blank">/occurrence/count?country=CANADA&georeferenced=true&basisOfRecord=OBSERVATION</a>.
        Note that country is the full name, not ISO code. This will change to ISO code in v1.0 of the API.
      </@trowM>
      <@trowM url="/count/schema" resp="Count" respLink="/occurrence/count/schema">List the supported schemas by the occurrence/count service.</@trowM>
      <@trowM url="/counts/basis_of_record" resp="Counts" respLink="/occurrence/counts/basis_of_record">Lists occurrence counts by basis of record.</@trowM>
      <@trowM url="/counts/countries"resp="Counts" respLink="/occurrence/counts/countries?publishingCountry=US" params=["publishingCountry"]>Lists occurrence counts by publishing country.</@trowM>
      <@trowM url="/counts/year" resp="Counts" respLink="/occurrence/counts/year?from=2000&to=20012" params=["from","to"]>Lists occurrence counts by year.</@trowM>
    </@api.apiTable>
</@api.article>


<@api.article id="inventories" title="Occurrence Inventories">
  <p>This API provides services that list all distinct values together with their occurrence count for a given occurrence property.
     Only a few properties are supported, each with its own service to call.
  </p>

  <@api.apiTable auth=false paging=false>
    <@trowM url="/occurrence/counts/datasets" resp="UUID Counts" respLink="/occurrence/counts/datasets?country=DE" params=["country","nubKey"]>Returns occurrence counts for datasets that cover a given taxon or country.</@trowM>
    <@trowM url="/occurrence/counts/countries" resp="Country Counts" respLink="/occurrence/counts/countries?publishingCountry=DE" params=["publishingCountry"]>Returns occurrence counts for all countries covered by the data published by the given country.</@trowM>
    <@trowM url="/occurrence/counts/publishingCountry" resp="Country Counts" respLink="/occurrence/counts/publishing_countries?country=DE" params=["country"]>Returns occurrence counts for all countries that publish data about the given country.</@trowM>
  </@api.apiTable>
</@api.article>

<#assign params = {
  "datasetKey": "The occurrence dataset key (a uuid)",
  "year": "The 4 digit year. A year of 98 will be interpreted as AD 98.",
  "month": "The month of the year, starting with 1 for January.",
  "date": "Occurrence date in ISO 8601 format: yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd.",
  "modified": "Occurrence modification date in ISO 8601 format: yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd.",
  "latitude": "Latitude in decimals between -90 and 90 based on WGS 84.",
  "longitude": "Longitude in decimals between -180 and 180 based on WGS 84.",
  "country": "The 2-letter country code (as per <a href='http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm' target='_blank'>ISO-3166-1</a>) of the country in which the occurrence was recorded.",
  "publishingCountry" : "The 2-letter country code (as per <a href='http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm' target='_blank'>ISO-3166-1</a>) of the country in which the occurrence was recorded.",
  "altitude": "Altitude/elevation in meters above sea level.",
  "depth" : "Depth in meters relative to altitude. For example 10 meters below a lake surface with given altitude.",
  "institutionCode" : "An identifier of any form assigned by the source to identify the institution the record belongs to. Not guaranteed to be unique.",
  "collectionCode": "An identifier of any form assigned by the source to identify the physical collection or digital dataset uniquely within the context of an institution.",
  "catalogNumber": "An identifier of any form assigned by the source within a physical collection or digital dataset for the record which may not be unique, but should be fairly unique in combination with the institution and collection code.",
  "collectorName": "The person who recorded the occurrence.",
  "basisOfRecord": "Basis of record, as defined in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/BasisOfRecord.html' target='_blank'>BasisOfRecord enum</a>",
  "taxonKey": "A taxon key from the GBIF backbone. All included and synonym taxa are included in the search, so a search for aves with taxonKey=212 (i.e. <a href='http://api.gbif.org/v0.9/occurrence/search?taxonKey=212' target='_blank'>/occurrence/search?taxonKey=212</a>) will match all birds, no matter which species.",
  "nubKey": "Same as <a href='#taxonKey'>taxon key</a>, a taxon id from the GBIF backbone.",
  "georeferenced": "Limits searches to occurrence records which contain a value in both latitude and longitude (i.e. georeferenced=true limits to occurrence records with coordinate values and georeferenced=false limits to occurrence records without coordinate values).",
  "geometry": "Searches for occurrences inside a polygon described in Well Known Text (WKT) format. A WKT shape written as POLYGON ((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1)) would be queried as is, i.e. <a href='http://api.gbif.org/v0.9/occurrence/search?geometry=POLYGON((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1))' target='_blank'>/occurrence/search?geometry=POLYGON((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1))</a>.",
  "spatialIssues": "Includes/excludes occurrence records which contain spatial issues (as determined in our record interpretation), i.e. spatialIssues=true returns only those records with spatial issues while spatialIssues=false includes only records without spatial issues. The absence of this parameter returns any record with or without spatial issues.",
  "q" : "Simple search parameter. The value for this parameter can be a simple word or a phrase.",
  "limit": "The maximum number of results to return. This can't be greater than 300, any value greater is set to 300.",    
  "from" : "The minimum year for which to return occurrences.",
  "to" : "The maximum year for which to return occurrences."
} />


<@api.paramArticle params=params apiName="Occurrence" />


<@common.article id="predicates" title="Occurrence Download Predicates">
    <div class="fullwidth">
        <p>A download predicate is an query expression to retrieve occurrence record downloads.</p>
        <p>If you are interested in seeing some examples of how to use the Java API to build predicates, there are some <a href="http://gbif-occurrencestore.googlecode.com/svn/occurrence-download/trunk/occurrence-download-ws/src/test/java/org/gbif/occurrencestore/download/service/HiveQueryVisitorTest.java" target="_blank">test cases</a> that can be used as a reference.</p>
        <p>The table below lists the supported predicates that can be combined to build download requests.</p>

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
                          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[{"type":"equals","key":"SPATIAL_ISSUES","value":"false"},<br/>
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
                          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[{"type":"equals","key":"SPATIAL_ISSUES","value":"false"},<br/>
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
