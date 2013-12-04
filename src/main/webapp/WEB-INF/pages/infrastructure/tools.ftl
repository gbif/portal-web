<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Tools</title>
    <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
</head>
<#assign tab="tools"/>
<#include "/WEB-INF/pages/infrastructure/inc/infoband.ftl" />


<body>

<#macro toolsTable>
    <table class='table table-bordered table-striped table-params'>
        <thead>
        <tr>
            <th width="18%">Name</th>
            <th width="17%">Categories of use</th>
            <th width="48%">Short Description</th>
            <th width="5%">Demo site</th>
            <th width="5%">Project site</th>
            <th width="5%">Mailing list</th>
        </tr>
        </thead>

        <tbody>
          <#nested />
        </tbody>
    </table>
</#macro>

<#macro trow name link categories demoLink="" projectLink="" mailingList="">
    <tr>
        <td><a href="${link}">${name}</a></td>
        <td>${categories}</a></td>
        <td><#nested/></td>
        <td><#if demoLink?has_content><a href="${demoLink}" target="_blank">Link</a></#if></td>
        <td><#if projectLink?has_content><a href="${projectLink}" target="_blank">Link</a></#if></td>
        <td><#if mailingList?has_content><a href="${mailingList}" target="_blank">Link</a></#if></td>
    </tr>
</#macro>

<@common.article id="about" title="GBIF Tools Overview">
  <div class="fullwidth">
      <p>
          GBIF makes available several free to use, open-source tools and services.
          The table below lists GBIF's most widely used and talked-about tools. They span several categories of use,
          such as data assessment, data cleaning, data publishing, data visualization, and metadata authoring. A longer list of
          tools can be found on <a href="http://tools.gbif.org/" target="_blank">http://tools.gbif.org/</a>.
      </p>
    <@toolsTable>
      <@trow name="Integrated Publishing Toolkit (IPT)" link="/ipt" categories="Data publishing, Metadata authoring, Data discovery" demoLink="http://ipt.gbif.org/" projectLink="https://code.google.com/p/gbif-providertoolkit/" mailingList="http://lists.gbif.org/mailman/listinfo/ipt">Publishes primary occurrence data, species checklists and taxonomies, and general metadata about data sources. It can also serve as a repository for data referenced in an article.</@trow>
      <@trow name="Nodes Portal Toolkit (NPT) Startup" link="#npt" categories="Data discovery" demoLink="http://nptstartup.gbif.org" projectLink="https://github.com/gbif/gbif-npt-startup" mailingList="http://lists.gbif.org/mailman/listinfo/npt-users">Enables participants to establish a simple, GBIF-compliant web presence</@trow>
      <@trow name="Darwin Core Archive Validator" link="#validator" categories="Data assessment" demoLink="http://tools.gbif.org/dwca-validator" projectLink="https://code.google.com/p/darwincore/">Validates that a Darwin Core Archive complies with the Darwin Core Text Guidelines</@trow>
      <@trow name="Name Parser" link="#parser" categories="Data cleaning" demoLink="http://tools.gbif.org/nameparser/" projectLink="https://code.google.com/p/taxon-name-processing/wiki/NameParsing">Atomizes scientific names, and validates that a scientific name is a well-formed 3-part name</@trow>
    </@toolsTable>
  </div>
</@common.article>


<@common.article id="npt" title="Nodes Portal Toolkit (NPT) Startup" titleRight="See also">
  <div class="left">
      <p>
          NPT Startup is a tool that targets GBIF Participants who have limited web presence. It helps establish the
          Node’s identity on the web, manage biodiversity information at the country/thematic level, and engage local
          and global communities in bringing up the relevance of biodiversity information.
      </p>

      <p>NPT Startup is one of the outcomes of the <a href="/capacityenhancement/npt">Nodes Portal Toolkit project (NPT)</a>, which identifies the need for
          facilitating the development of national and thematic biodiversity portals with reusable biodiversity
          informatics components. NPT Startup is built with Drupal content management framework backed by a strong,
          fast-growing, open-source community. Collaborating together with ViBRANT and INBio, NPT Startup is a
          proof-of-concept of joint development.
      </p>

      <p>By deploying NPT Startup, a website will be ready for you with initial national checklist derived from GBIF
          mediated data and species contents (descriptions, images and videos) from the Encyclopedia of Life. Common website
          features like news and RSS feeds will available for you too. There are thousands of features from the Drupal
          community, so you can easily extend and customise NPT Startup to serve your needs.
      </p>

      <p>
          The following video presents the NPT Startup in more detail.
      </p>

      <p>
        <iframe src="//player.vimeo.com/video/63640790" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      </p>
  </div>
    <div class="right">
        <h3>Resources</h3>
        <ul>
            <li><a href="https://github.com/gbif/gbif-npt-startup/releases" title="NPT download" target="_blank">Download</a></li>
            <li><a href="http://nptstartup.gbif.org" title="NPT demo site" target="_blank">Demo site</a></li>
            <li><a href="https://github.com/gbif/gbif-npt-startup" title="NPT project home" target="_blank">Project site</a></li>
            <li><a href="https://github.com/gbif/gbif-npt-startup/wiki" title="NPT wiki" target="_blank">Wiki</a></li>
            <li><a href="http://lists.gbif.org/mailman/listinfo/npt-users" title="NPT mailing list" target="_blank">Mailing list</a></li>
        </ul>
        <h3>Feedback</h3>
        <ul>
            <li><a href="https://github.com/gbif/gbif-npt-startup/issues" title="IPT Report a bug" target="_blank">Report an issue</a></li>
        </ul>
    </div>
</@common.article>


<@common.article id="validator" title="Darwin Core Archive Validator" titleRight="See also">
    <div class="left">
        <p>
            Helps you validate that a Darwin Core Archive complies with the Darwin Core Text Guidelines. It validates
            that the metadata file complies with the GBIF Metadata Profile and the Ecological Markup Language (EML). It
            also inspects the mapped concepts against the extensions registered with GBIF, identifying unknown or
            required concepts that are missing.
        </p>

        <p>
            It doesn’t perform any data assessment (i.e. taxonomic or geospatial assessments), however, it does visualize
            the first 100 rows, helping you identify bad mappings or missing data.
        </p>

        <p>
            <a href="http://tools.gbif.org/dwca-validator" target="_blank">Try it out</a> now online, or by playing with
            its <a href="http://tools.gbif.org/dwca-validator/api.do" target="_blank">web services</a>.
        </p>
        <p>
            Please note that this will likely be included in the <a href="../../developer">GBIF API</a> in future versions.
        </p>

    </div>
    <div class="right">
        <h3>Resources</h3>
        <ul>
            <li><a href="http://tools.gbif.org/dwca-validator" title="Darwin Core Archive Validator HTML form" target="_blank">Try it out</a></li>
            <li><a href="http://tools.gbif.org/dwca-validator/api.do" title="Darwin Core Archive Validator API" target="_blank">Web service API</a></li>
            <li><a href="https://code.google.com/p/darwincore/" title="Darwin Core Archive Validator project home" target="_blank">Project site</a></li>
        </ul>
        <h3>Feedback</h3>
        <ul>
            <li><a href="https://code.google.com/p/darwincore/issues/entry" title="Darwin Core Archive Validator Report a bug" target="_blank">Report an issue</a></li>
        </ul>
    </div>
</@common.article>

  <@common.article id="parser" title="Name Parser" titleRight="See also">
      <div class="left">
          <p>
              Helps you atomize scientific names, and validate that a scientific name is a well-formed 3-part name. The parser is based on regular expressions to dissect a name string into its components.
          </p>

          <p>
              <a href="http://tools.gbif.org/nameparser/" target="_blank">Try it out</a> now online, or by playing with
              its <a href="http://tools.gbif.org/nameparser/api.do" target="_blank">web services</a>.
          </p>
          <p>
              Please note that this will likely be included in the <a href="../../developer">GBIF API</a> in future versions.
          </p>

      </div>
      <div class="right">
          <h3>Resources</h3>
          <ul>
              <li><a href="http://tools.gbif.org/nameparser/" title="Name Parser HTML form" target="_blank">Try it out</a></li>
              <li><a href="http://tools.gbif.org/nameparser/api.do" title="Name Parser API" target="_blank">Web service API</a></li>
              <li><a href="https://code.google.com/p/taxon-name-processing" title="Name Parser project home" target="_blank">Project site</a></li>
              <li><a href="https://code.google.com/p/taxon-name-processing/wiki/NameParsing" title="NPT wiki" target="_blank">Wiki</a></li>
          </ul>
          <h3>Feedback</h3>
          <ul>
              <li><a href="https://code.google.com/p/taxon-name-processing/issues/entry" title="Name Parser Report a bug" target="_blank">Report an issue</a></li>
          </ul>
      </div>
  </@common.article>

</body>
</html>