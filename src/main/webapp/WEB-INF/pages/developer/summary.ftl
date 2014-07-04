<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>GBIF API</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
  <style>
    ul.indent, ol.indent {
      margin: 0 30px 0 30px;
    }
  </style>
</head>

<#include "/WEB-INF/pages/developer/inc/tabs.ftl" />

<body class="api">

<@api.introArticle>
<div class="left">
    <p>The GBIF API provides registration, discovery and access and information services.</p>
    <p>The API is a RESTful JSON based API. The base URL for v1 you are going to use is:</p>
    <ul class="indent">
        <li><strong>${action.cfg.apiBaseUrl}</strong></li>
    </ul>
    <p>The API is split into logical sections to ease understanding:</p>
    <ul class="indent">
      <li><strong>Registry:</strong> Provides means to create, edit, update and search for information about the datasets,
      organizations (e.g. data publishers), networks and the means to access them (technical endpoints).  The registered
      content controls what is crawled and indexed in the GBIF data portal, but as a shared API may also be used for other
      initiatives</li>
      <li><strong>Species:</strong> Provides services to discover and access information about species and higher taxa, and
      utility services for interpreting names and looking up the identifiers and complete scientific names used for species in
      the GBIF portal.</li>
      <li><strong>Occurrence:</strong> Provides access to occurrence information crawled and indexed by GBIF and search services
      to do real time paged search and asynchronous download services to do large batch downloads.</li>
      <li><strong>Maps:</strong> Provides simple services to show the maps of GBIF mobilized content on other sites.</li>
      <li><strong>News feed:</strong> Provides services to stream useful information such as papers published using GBIF mobilized
      content for various themes.</li>
    </ul>
    <p>
      For the <strong>Registry</strong>, <strong>Species</strong>, <strong>Occurrence</strong>, and <strong>Maps</strong> sections, Java web service clients exist. Please see each section's introduction for more information.
    </p>
    <p>
      You can also sign up to the <a href="http://lists.gbif.org/mailman/listinfo/api-users" target="_blank">GBIF API users mailing list</a> to post your questions,
        and to keep informed about the API. We will announce new versions, and scheduled maintenance downtimes before they happen.
    </p>
    <p>
      We welcome any example uses of the API to guest feature on the <a href="http://gbif.blogspot.com">GBIF developer blog</a>.
    </p>
    <p>
        Lastly while the API is nearing stability for the first formal release, this documentation is also in first edition.  Please
        consider reporting issues found with the documentation using the "feedback" button on the right to help improve the
        content.
    </p>
</div>
<div class="right">
    <ul>
      <li><a href="#common">Common operations</a></li>
      <li><a href="#roadmap">Roadmap to v2</a></li>
      <li><a href="http://lists.gbif.org/mailman/listinfo/api-users" target="_blank">GBIF API users mailing list</a></li>
    </ul>
</div>
</@api.introArticle>


<@common.article id="common" title="Common operations">
  <div class="fullwidth">
    <p>The following details common cross-cutting parameters used in the API<p>

    <h3>Paging</h3>
    <p>For requests that support paging the following parameters are used:</p>
    <table class="table table-bordered table-striped table-params">
      <thead>
        <tr>
          <th width="25%" class="total">Parameter</th>
          <th width="75%">Details</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>limit</td>
          <td>Controls the number of results in the page.  Using too high a value will be overwritten with the default
            maximum threshold, depending on the service.  Sensible defaults are used so this may be omitted.</td>
        </tr>
        <tr>
          <td>offset</td>
          <td>Determines the offset for the search results.  A limit of 20 and offset of 20, will get the second page
          of 20 results.</td>
        </tr>
      </tbody>
    </table>


    <h3>Range queries</h3>
    <p>Some search parameters support range queries, for example the <em>year</em> parameter in the occurrence search.
      In general ranges are given as a single parameter value by concatenating a lower and an upper value with a comma.
      For example:
      <code><@api.url '/occurrence/search?year=1800,1899'/></code>
    </p>

      <h3>Authentication</h3>
      <p>POST, PUT, and DELETE requests require authentication. The GBIF API uses basic authentication with any GBIF
          user account that you have created before.
          For example:
          <code>$ curl -i --user yourUserName:yourPassword -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d @dataset.json ${action.cfg.apiBaseUrl}/dataset</code>
      </p>
  </div>
</@common.article>

<@common.article id="roadmap" title="Roadmap to v2">
  <div class="fullwidth">
    <p>The GBIF API is currently at v1 which means:<p>
    <ol class="indent">
      <li>The API is stable but changes might occur in the future leading to v2 (currently there are no known changes)</li>
       <li>Developers building applications using the API should be ready to follow any changes in the API, which will be announced</li>
       <li>When v2 is released, adopters will be encouraged to update immediately, since v1 will only be kept online for a brief transition period</li>
       <li>The base URL includes the version as appropriate</li>
    </ol>
    <p>Feedback from developers on the API can be sent to <a href="mailto:dev@gbif.org">dev@gbif.org</a></p>
  </div>
</@common.article>

</body>
</html>
