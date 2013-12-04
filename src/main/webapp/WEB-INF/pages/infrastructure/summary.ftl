<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Summary</title>
</head>
<#assign tab="summary"/>
<#include "/WEB-INF/pages/infrastructure/inc/infoband.ftl" />

<body>

<@common.article id="about" title="About" titleRight="See also" class="rte">
  <div class="left">
    <p>The GBIF informatics architecture provides an open platform to connect and access biodiversity databases around the world.</p>
    <p>The distributed infrastructure spans across the hundreds of institutions participating in GBIF enabling users to discover, access, integrate and help curate the growing content shared on the network.</p>
    <p>The GBIF architecture encompases well-known community-developed data standards and protocols enabling interoperability at global scale. As an open infrastructure, a growing number of tools and workflows are able to connect and participate in the GBIF network.</p>
    <p>For convenience the infrastructure can be considered in terms of a number of sequential processes:</p>
    <p>
    <ol>
     <ol>
<li><strong>Digitization</strong>: The initial capturing of information in electronic form, through imaging, databasing, maintaining spreadsheets etc.</li>
<li><strong>Publishing</strong>: The act of making data sources available in a well known format (standard) and with appropriate metadata for access on the internet.</li>
<li><strong>Integration</strong>: The process of aggregating published data sets, applying consistent quality control routines and normalizing formats.</li>
<li><strong>Discovery and access</strong>: By building network wide indexes, discovery services are offered for users through portals and for machines by extensive web service APIs.</li>
     </ol>
    </ol>
  </div>
  <div class="right">
    <ul>
      <li><a href="${cfg.drupal}/publishingdata/summary" title="Data publishing">How to publish data?</a></li>
    </ul>
  </div>
</@common.article>

</body>
</html>