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

<@common.notice title="Feedback sought">
  <p>The API is currently at vesion v0.9 and is nearing stability - it powers all functions of this portal.</p>
  <p>Please report issues to <a href="mailto:dev@gbif.org">dev@gbif.org</a> and help us move to a stable v1
  (expected June 2014)</p>
</@common.notice>


<@api.introArticle>
<div class="left">
    <p>The GBIF API provides registration, discovery and access and information services.</p>
    <p>The API is a RESTful JSON based API. The base URL for v0.9 you are going to use is:</p>
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
      <li><a href="#roadmap">Roadmap to v1</a></li>
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
  </div>
</@common.article>

<@common.article id="roadmap" title="Roadmap to v1">
  <div class="fullwidth">
  <p>The GBIF API is currently at v0.9 which means:<p>
  <ol class="indent">
     <li>The API is nearing stability but changes might occur before v1 (see below for a list of known changes)</li>
     <li>Developers building applications using the API should be ready to follow any changes in the API, which will be announced</li>
     <li>When v1 is released, adopters will be encouraged to update immediately, since v0.9 will only be kept online for a brief transition period</li>
     <li>The base URL includes the version as appropriate</li>
  </ol>
  <p>Known changes that will occur:</p>
  <ol class="indent">
    <li>The occurrence response will be reviewed to align closer to the Darwin Core</li>
    <li>The occurrence API will support searching by scientific name</li>
    <li>All query parameters for countries will be converted into ISO country codes where currently (e.g.) DENMARK is used</li>
    <li>Occurrence multimedia will be interpreted</li>
  </ol>
  <p>Feedback is sought from developers on the API structure, before the frozen v1 will be released to <a href="mailto:dev@gbif.org">dev@gbif.org</a></p>

  <p>v1 is expected in <strong>June 2014</strong> unless feedback received indicates it should be delayed</p>
  </div>
</@common.article>

</body>
</html>
