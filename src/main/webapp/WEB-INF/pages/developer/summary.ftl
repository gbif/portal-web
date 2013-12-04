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
  <p>Please report issues to <a href="mailto:dev@gbif.org">dev@gbif.org</a> and help us move to a stable v1.0
  (expected December 2013)</p>
</@common.notice>


<@api.introArticle>
<div class="left">
    <p>The GBIF API provides registration, discovery and access and information services in a RESTful manner.</p>
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
      The API is a RESTful JSON based API, and for all components Java libraries exist.
    </p>
    <p>
      While the API is nearing stability for the first formal release, this documentation is also in first edition.  Please
      consider reporting issues found with the documentation using the "feedback" button on the right to help improve the
      content.
    </p>
    <p>
      We welcome any example uses of the API to guest feature on the <a href="http://gbif.blogspot.com">GBIF developer blog</a>.
    </p>
</div>
<div class="right">
    <ul>
      <li><a href="#common">Common operations</a></li>
      <li><a href="#roadmap">Roadmap to v1.0</a></li>
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
  </div>
</@common.article>

<@common.article id="roadmap" title="Roadmap to v1.0">
  <div class="fullwidth">
  <p>The GBIF api is currently at v0.9 which means:<p>
  <ol class="indent">
     <li>The API is nearing stability but changes might occur before v1.0</li>
     <li>Developers building applications using the API should be ready to follow any changes in the API, which will be announced</li>
     <li>v0.9 <em>may</em> not be maintained when v1.0 is released</li>
     <li>The base URL includes the version as appropriate</li>
  </ol>
  <p>Known changes that will occur:</p>
  <ol class="indent">
    <li>The occurrence response will be reviewed to align closer to the Darwin Core</li>
    <li>The occurrence API will support searching by scientific name</li>
    <li>All query parameters for countries will be converted into ISO country codes where currently (e.g.) DENMARK is used</li>
  </ol>
  <p>Feedback is sought from developers on the API structure, before the frozen v1.0 will be released to <a href="mailto:dev@gbif.org">dev@gbif.org</a></p>

  <p>v1.0 is expected in <strong>December 2013</strong> unless feedback received indicates it should be delayed</p>
  </div>
</@common.article>

</body>
</html>
