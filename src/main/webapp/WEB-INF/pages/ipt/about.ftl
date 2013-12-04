<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>IPT</title>
</head>

<#include "/WEB-INF/pages/ipt/inc/infoband.ftl" />


<body class="ipt">

<@common.article id="about" title="About the IPT" titleRight="See also">
  <div class="left">
      <p>The Integrated Publishing Toolkit (IPT) is a free open source software tool written in Java that is used to publish and share biodiversity datasets through the GBIF network. Designed for interoperability, it enables the publishing of content in databases or text files using open standards namely the <a href="http://rs.tdwg.org/dwc/terms/" title="Darwin Core Terms" target="_blank">Darwin Core</a> and the <a href="http://knb.ecoinformatics.org/software/eml/" title="EML" target="_blank">Ecological Metadata Language</a>. You can also use a 'one-click' service to convert your metadata into a draft <a href="/publishingdata/datapapers" title="How to publish data papers">data paper manuscript</a> for submission to a peer-reviewed journal.</p>
      <p>The core development of the IPT happens at the GBIF Secretariat, but the coding, documentation, and internationalization are a community effort and everyone is welcome to join in. New versions incorporate the feedback from the people who actually use the IPT. In this way, users can help get the features they want by becoming involved. The IPT really is a community-driven tool.</p>
      <p>You can see the work that has gone into each iterative version since v2.0.3 (released in November 2011) under the <a href="/drupal/ipt/releases" title="IPT Releases Tab">Releases</a> tab. You can check out the <a href="/drupal/ipt/stats" title="IPT Stats Tab">Stats</a> page to find out how many institutions around the world are using the IPT today.</p>
  </div>
  <div class="right">
      <h3>Resources</h3>
      <ul>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPT2ManualNotes?tm=6" title="IPT User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPT2ManualNotes?wl=es" title="IPT User Manual Spanish">(es)</a></li>
          <li><a href="http://lists.gbif.org/mailman/listinfo/ipt" title="IPT Mailing List" target="_blank">Mailing List</a></li>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPT2ManualNotes?tm=6" title="IPT Wiki" target="_blank">Wiki</a></li>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/wiki/FAQ" title="IPT FAQ" target="_blank">FAQs</a></li>
      </ul>
      <h3>Feedback</h3>
      <ul>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/issues/entry" title="IPT Report a bug" target="_blank">Report a Bug</a></li>
          <li><a href="https://code.google.com/p/gbif-providertoolkit/issues/entry&amp;template=Feature request" title="IPT Request an enhancement" target="_blank">Request an Enhancement</a></li>
      </ul>
  </div>
</@common.article>


<@common.article id="iptfeatures" title="Features">
  <div class="fullwidth">
      <div class="inner">
          <ul>
              <li class="iptfeature">
                  <div class="imgbox-tall">
                      <img typeof="foaf:Image" src="/img/ipt/types.jpg" width="221" height="162" alt="Resource type selection on IPT Create New Resource Form" title="Resource type selection on IPT Create New Resource Form" />
                  </div>
                  <div class="title">Publication of three types of biodiversity data:</div>
                  <p>I. Primary occurrence data (specimens, observations)</p>
                  <p>II. Species checklists and taxonomies</p>
                  <p>III. General metadata about data sources</p>
              </li>
              <li class="iptfeature">
                  <div class="imgbox-tall">
                      <img typeof="foaf:Image" src="/img/ipt/languages.jpg" width="206" height="148" alt="Language selection in IPT" title="Language selection in IPT" />
                  </div>
                  <div class="title">Internationalization</div>
                  <p>User interface available in five different languages: English, French, Spanish, Traditional Chinese, Brazilian Portuguese.</p>
              </li>
              <li class="iptfeature last">
                  <div class="imgbox-tall">
                      <img typeof="foaf:Image" src="/img/ipt/security.jpg" width="213" height="148" alt="Visibility and Resource Managers sections of IPT Manage Resource Page" title="Visibility and Resource Managers sections of IPT Manage Resource Page" />
                  </div>
                  <div class="title">Data Security</div>
                  <p>Controls access to datasets using three levels of dataset visibility: private, public and registered. Controls which users can modify datasets, with four types of user roles.</p>
              </li>
              <li class="iptfeature">
                  <div class="imgbox-short">
                      <img typeof="foaf:Image" src="/img/ipt/registry.jpg" width="270" height="94" alt="GBIF Registration icon in IPT Administration page" title="GBIF Registration icon in IPT Administration page" />
                  </div>
                  <div class="title">Integration with GBIF Registry</div>
                  <p>Can automatically register datasets in the GBIF Registry. Registration enables global discovery of datasets in both the GBIF Registry, and GBIF Data Portal.</p>
              </li>
              <li class="iptfeature">
                  <div class="imgbox-short">
                      <img typeof="foaf:Image" src="/img/ipt/large_datasets.jpg" width="206" height="89" alt="Record count of eBird Dataset on Aug 9 2013 from VertNet IPT" title="Record count of eBird Dataset on Aug 9 2013 from VertNet IPT" />
                  </div>
                  <div class="title">Support for large datasets</div>
                  <p>Can process ~500,000 records/minute during publication. Disk space the only limiting factor. For example, a published dataset with 50 million records in DwC-A format is 3.6 GB.</p>
              </li>
              <li class="iptfeature last">
                  <div class="imgbox-short">
                      <img typeof="foaf:Image" src="/img/ipt/standards.jpg" width="234" height="100" alt="Published releases section on IPT Manage Resource Page" title="Published releases section on IPT Manage Resource Page" />
                  </div>
                  <div class="title">Standards-compliant publishing</div>
                  <p>Publishes a dataset in Darwin Core Archive (DwC-A) format, a compressed set of files based on the <a href="http://rs.tdwg.org/dwc/terms/" title="Darwin Core Terms" target="_blank">Darwin Core terms</a>, and the <a href="http://www.gbif.org/orc/?doc_id=2820" title="GBIF Metadata Profile">GBIF metadata profile</a> built using the <a href="http://knb.ecoinformatics.org/software/eml/eml-2.1.1/" title="EML" target="_blank">Ecological Metadata Language</a>.</p>
              </li>
          </ul>
      </div>
  </div>
</@common.article>

<@common.article id="contribute" title="How to contribute?" titleRight="Featured users">
    <div class="left">
        <h3>Translation</h3>
        <p>Has the IPT user interface or documentation been translated into your native language yet? If not, we welcome new translations into any language. Instructions can be found <a href="https://code.google.com/p/gbif-providertoolkit/wiki/HowToContribute" title="Instructions on translating the IPT User Interface" target="_blank">here</a>.</p>
        <h3>Code</h3>
        <p>Is the IPT missing a key feature, or is the GBIF Secretariat too slow getting around to implementing an existing feature request or bug fix? Feel free to contribute a code patch yourself. To start, check out the latest version of the source code <a href="https://code.google.com/p/gbif-providertoolkit/source/checkout" title="Link to download IPT source code from SVN" target="_blank">here</a>.</p>
        <h3>Documentation</h3>
        <p>Is there a mistake in the IPT documentation? Perhaps some topic in the IPT wiki is missing? If so, please contact the <a href="mailto:helpdesk@gbif.org" title="GBIF Helpdesk Email">GBIF Helpdesk</a> with your ideas, and we will grant you author privileges to the IPT wiki.</p>
    </div>
    <div class="right">
        <p>"Darwin Core Archives are required for data harvest to our new portal. We see IPT as a great tool to facilitate the creation of these files and to provide hosting of them for our participating institutions." - <em>Laura Russell, VertNet</em></p>
        <p>"Thanks to the IPT we now have a complete data mobilization workflow, from in-house data management systems to GBIF. The software tool has been instrumental in the growth of the Canadensys network." - <em>Peter Desmet, INBO &amp; Canadensys</em></p>
        <p>"The IPT has facilitated primary data publication for us. At SiB Colombia we use it as a central part of our <a href="http://www.sibcolombia.net/web/sib/acerca-del-sib" target="_blank">data publication model</a>" - <em>Danny Vélez, SiB Colombia</em></p>
    </div>
</@common.article>

</body>
</html>