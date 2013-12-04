<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>IPT</title>
</head>

<#assign tab="releases"/>
<#include "/WEB-INF/pages/ipt/inc/infoband.ftl" />


<body class="ipt">


<@common.article id="about" title="Latest release – version 2.0.5, 17 May 2013" titleRight="Version history">
  <div class="left">
    <p>This is the most autonomous version of the IPT to date, including a new feature called automatic publishing that allows you to configure a resource to publish on an interval. This way, you only ever have to press the publish button once! Also every published version is now resolvable, allowing you to track a resource's history over time. And lastly thanks to the efforts of Etienne Cartolano, Allan Koch Veiga, and Antonio Mauro Saraiva from the <a href="http://www.biocomp.org.br/" title="Link to Sao Paulo" target="_blank">Universidade de São Paulo, Research Center on Biodiversity and Computing</a> the IPT is now available in Portuguese, the IPT's 5th translation of the user interface.</p>
    <p>
      <h3><a href="https://gbif-providertoolkit.googlecode.com/files/ipt-2.0.5-security-update-1.war" title="Link to download IPT v2.0.5">Download</a></h3>
      <h3><a href="http://gbif.blogspot.dk/2013/05/ipt-v205-released-melhor-versao-ate-o.html" title="Link to release announcement about IPT v2.0.5" target="_blank">Release Announcement</a></h3>
      <h3><a href="https://gbif-providertoolkit.googlecode.com/files/Release Notes - IPT 2.0.5.txt" title="IPT v2.0.5 Release notes">Release notes (upgrade instructions)</a></h3>
    </p>
    <p>&nbsp;</p>
    <h2>Roadmap - what's next?</h2>
    <p>The next version of the IPT will be released in the 4th quarter of 2013. It will be called 2.1, and it will represent a major upgrade because it will be based on the brand-new GBIF Registry web services, developed as part of the new GBIF Data Portal. This will allow the IPT to overcome limitations of the old web services, such as only being able to register a single contact per dataset. This version will also address an <a href="https://code.google.com/p/gbif-providertoolkit/issues/detail?id=976" title="Link to IPT issue regarding temporary directory" target="_blank">issue</a> found in 2.0.5, where the IPT’s temporary directory fills up causing a disk out of space exception.</p>
    <p>As of August 8th, 2013 there were <a href="https://code.google.com/p/gbif-providertoolkit/issues/list?can=2&amp;q=Milestone%3DRelease2.1+&amp;colspec=ID+Type+Status+Priority+Milestone+Owner+Summary&cells=tiles" title="Link to issue scheduled to be included in IPT v2.1 release" target="_blank">11 issues</a> scheduled to be included in this release.</p>
  </div>
  <div class="right">
      <h3><strong>2.0.5</strong> - May, 2013</h3>
      <ul>
        <li><a href="https://gbif-providertoolkit.googlecode.com/files/ipt-2.0.5-security-update-1.war" title="Dowload IPT v2.0.5">Download</a> / <a href="https://gbif-providertoolkit.googlecode.com/files/Release Notes - IPT 2.0.5.txt" title="IPT v2.0.5 Release Notes">Notes</a></li>
        <li><a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPT2ManualNotes?tm=6" title="IPT User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPT2ManualNotes?wl=es" title="IPT User Manual Spanish" target="_blank">(es)</a></li>
        <li><a href="http://gbif.blogspot.dk/2013/05/ipt-v205-released-melhor-versao-ate-o.html" title="IPT v2.0.5 Release Announcement" target="_blank">Release Announcement</a></li>
        <li>Addressed <a href="http://code.google.com/p/gbif-providertoolkit/issues/list?can=1&amp;q=milestone%3DRelease2.0.5" title="IPT v2.0.5 Issues List" target="_blank">45 issues</a>: 15 Defects, 17 Enhancements, 2 Patches, 7 Won’t fix, 3 Duplicates, and 1 that was considered as Invalid
        </li>
        <li>Translated into 5 languages (Portuguese translation added)</li>
      </ul>
      <h3><strong>2.0.4</strong> - October, 2012</h3>
      <ul>
          <li><a href="https://gbif-providertoolkit.googlecode.com/files/ipt-2.0.4.war" title="Download IPT v2.0.4"><strike>Download</strike></a> / <a href="https://gbif-providertoolkit.googlecode.com/files/Release Notes - IPT 2.0.4.txt" title="IPT v2.0.4 Release Notes">Notes</a></li>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv204" title="IPT v2.0.4 User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv204?wl=es" title="IPT v2.0.4 User Manual Spanish" target="_blank">(es)</a></li>
          <li><a href="http://gbif.blogspot.dk/2012/10/ipt-v204-released.html" title="IPT v2.0.4 Release Announcement" target="_blank">Release Announcement</a></li>
          <li>Addressed <a href="http://code.google.com/p/gbif-providertoolkit/issues/list?can=1&amp;q=milestone%3DRelease2.0.4" title="IPT v2.0.4 Issues List" target="_blank">108 issues</a>: 38 Defects, 35 Enhancements, 7 Other, 5 Patches, 18 Won't fix, 4 Duplicates, and 1 that was considered as Invalid
          </li>
          <li>Translated into 4 languages (Traditional Chinese translation added)</li>
      </ul>
      <h3><strong>2.0.3</strong> - November, 2011</h3>
      <ul>
          <li><a href="https://gbif-providertoolkit.googlecode.com/files/ipt-2.0.3.war" title="Download IPT v2.0.3"><strike>Download</strike></a> / <a href="https://gbif-providertoolkit.googlecode.com/files/Release Notes - IPT 2.0.3.txt" title="IPT v2.0.4 Release Notes">Notes</a></li>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv203" title="IPT v2.0.3 User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv203?wl=es" title="IPT v2.0.3 User Manual Spanish" target="_blank">(es)</a></li>
          <li><a href="http://gbif.blogspot.dk/2011/11/important-quality-boost-for-gbif-data.html" title="IPT v2.0.3 Release Announcement" target="_blank">Release Announcement</a></li>
          <li>Addressed <a href="http://code.google.com/p/gbif-providertoolkit/issues/list?can=1&q=milestone%3DRelease2.0.3" title="IPT v2.0.3 Issues List" target="_blank">85 issues</a>: 43 defects, 31 enhancements, 3 Patches, 7 Won’t fix, and 1 Duplicate
          </li>
          <li>Translated into 3 languages (French and Spanish translations added)</li>
      </ul>
  </div>
</@common.article>

</body>
</html>