<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
    <title>IPT</title>
    <style>
        .plos-block {
            float: left;
            height: 160px;
            margin-top: 20px;
            overflow: hidden;
            position: relative;
            width: 597px;
        }
        .plos-block .details {
            bottom: 40px;
            height: 120px;
            padding: 27px 20px 0;
            position: absolute;
            right: 0;
            width: 570px;
            z-index: 2;
            font-size: 20px;
            line-height: 23px;
        }

        .plos-block .details a {
            color: #09c;
        }
        .plos-block .actions {
            bottom: 0;
            cursor: pointer;
            list-style-type: none;
            margin: 0;
            padding: 0;
            position: absolute;
            right: 0;
            z-index: 2;
        }
        .plos-block .actions li {
            border-right: 1px solid #616161;
            display: inline;
            float: left;
            width: 250px;
        }
        .plos-block .actions li.last {
            border: medium none;
            width: 340px;
        }
        .plos-block .actions li a {
            background: none repeat scroll 0 0 #09c;
            color: #fff;
            display: block;
            font-size: 15px;
            height: 40px;
            line-height: 40px;
            text-align: center;
            text-decoration: none;
        }
        #datacite {
            padding-right: 20px;
        }
    </style>
</head>

<#include "/WEB-INF/pages/ipt/inc/infoband.ftl" />


<body class="ipt">

<@common.article id="about" title="About the IPT" titleRight="See also">
    <div class="left">
        <p>The Integrated Publishing Toolkit (IPT) is a free open source software tool written in Java that is used to publish and share biodiversity datasets through the GBIF network. Designed for interoperability, it enables the publishing of content in databases, Microsoft Excel spreadsheets, or text files using open standards namely the <a href="http://rs.tdwg.org/dwc/terms/" title="Darwin Core Terms" target="_blank">Darwin Core</a> and the <a href="http://knb.ecoinformatics.org/software/eml/" title="EML" target="_blank">Ecological Metadata Language</a>.You can also use a 'one-click' service to convert your metadata into a draft <a href="/publishingdata/datapapers" title="How to publish data papers">data paper manuscript</a> for submission to a peer-reviewed journal.</p>
        <img id="datacite" typeof="foaf:Image" align="left" src="/img/ipt/datacite-logo-web.png" width="105" height="100" alt="DataCite logo 2015" title="DataCite logo 2015" /><p>Since v2.2, the IPT has been capable of automatically connecting with either DataCite or EZID to assign DOIs to datasets. This new feature makes biodiversity data easier to access on the Web and facilitates tracking its re-use. You may read more about this and other new features introduced in version 2.2 <a href="http://gbif.blogspot.com/2015/03/ipt-v22.html" title="Version 2.2 blog post" target="_blank">here</a>.</p>
        <p>The core development of the IPT happens at the GBIF Secretariat, but the coding, documentation, and internationalization are a community effort and everyone is welcome to join in. New versions incorporate the feedback from the people who actually use the IPT. In this way, users can help get the features they want by becoming involved. The IPT really is a community-driven tool.</p>
        <p>You can see the work that has gone into each iterative version since v2.0.3 (released in November 2011) under the <a href="/ipt/releases" title="IPT Releases Tab">Releases</a> tab. You can check out the <a href="/ipt/stats" title="IPT Stats Tab">Stats</a> page to find out how many institutions around the world are using the IPT today.</p>
        <p>For a more in-depth description of the IPT, including why it was developed, you can read <a href="http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0102623" title="The GBIF Integrated Publishing Toolkit: Facilitating the Efficient Publishing of Biodiversity Data on the Internet">this</a> article published in PLOS ONE on August 6, 2014.</p>
        <div class="plos-block">

            <div class="details">
                <img alt="PLOS ONE" src="/img/ipt/plos_one_logo.png" width="191" height="41" border="0"/>
                <div>
                    <a href="http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0102623">The GBIF Integrated Publishing Toolkit: Facilitating the Efficient Publishing of Biodiversity Data on the Internet</a>
                </div>
            </div>
            <ul class="actions">
                <li><a href="http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0102623">Full Text</a></li>
                <li class="last"><a href="http://www.plosone.org/article/fetchObject.action?uri=info%3Adoi%2F10.1371%2Fjournal.pone.0102623&representation=PDF">Download: Full Article PDF Version</a></li>
            </ul>
        </div>
    </div>
    <div class="right">
        <h3>Resources</h3>
        <ul>
            <li><a href="https://github.com/gbif/ipt/wiki/IPT2ManualNotes.wiki" title="IPT User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPT2ManualNotes?wl=es" title="IPT User Manual Spanish">(es)</a></li>
            <li><a href="http://lists.gbif.org/mailman/listinfo/ipt" title="IPT Mailing List" target="_blank">Mailing List</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki" title="IPT Wiki" target="_blank">Wiki</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/FAQ.wiki" title="IPT FAQ" target="_blank">FAQs</a></li>
        </ul>
        <h3>Feedback</h3>
        <ul>
            <li><a href="https://github.com/gbif/ipt/issues" title="IPT Report a bug" target="_blank">Report a Bug</a></li>
            <li><a href="https://github.com/gbif/ipt/issues" title="IPT Request an enhancement" target="_blank">Request an Enhancement</a></li>
        </ul>
    </div>
</@common.article>


<@common.article id="iptfeatures" title="Features">
    <div class="fullwidth">
        <div class="inner">
            <ul>
                <li class="iptfeature">
                    <div class="imgbox-short">
                        <img typeof="foaf:Image" src="/img/ipt/GBIF-2015-dotorg-stacked.png" width="72" height="72" alt="GBIF logo 2015" title="GBIF logo 2015" />
                        <img typeof="foaf:Image" src="/img/ipt/datacite-logo-web.png" width="72" height="72" alt="DataCite logo 2015" title="DataCite logo 2015" />
                        <img typeof="foaf:Image" src="/img/ipt/ezid2.png" width="94" height="38" alt="EZID logo 2015" title="EZID logo 2015" />
                    </div>
                    <div class="title">Integration with GBIF, DataCite, EZID</div>
                    <p>Can automatically register datasets with GBIF making them globally discoverable through the GBIF website. Can also automatically connect with either DataCite or EZID to assign DOIs to datasets.</p>
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
                <li class="iptfeature">
                    <div class="imgbox-tall">
                        <img typeof="foaf:Image" src="/img/ipt/types2.png" width="174" height="162" alt="Resource type selection on IPT Create New Resource Form" title="Resource type selection on IPT Create New Resource Form" />
                    </div>
                    <div class="title">Publication of four types of biodiversity data:</div>
                    <p>I. Primary occurrence data (specimens, observations)</p>
                    <p>II. Species checklists and taxonomies</p>
                    <p>III. Sample-based data (data about sampling events)</p>
                    <p>IV. General metadata about data sources</p>
                </li>
                <li class="iptfeature">
                    <div class="imgbox-tall">
                        <img typeof="foaf:Image" src="/img/ipt/languages.jpg" width="206" height="148" alt="Language selection in IPT" title="Language selection in IPT" />
                    </div>
                    <div class="title">Internationalization</div>
                    <p>User interface available in six different languages: English, French, Spanish, Traditional Chinese, Brazilian Portuguese, and Japanese.</p>
                </li>
                <li class="iptfeature last">
                    <div class="imgbox-tall">
                        <img typeof="foaf:Image" src="/img/ipt/security.jpg" width="213" height="148" alt="Visibility and Resource Managers sections of IPT Manage Resource Page" title="Visibility and Resource Managers sections of IPT Manage Resource Page" />
                    </div>
                    <div class="title">Data Security</div>
                    <p>Controls access to datasets using three levels of dataset visibility: private, public and registered. Controls which users can modify datasets, with four types of user roles.</p>
                </li>
            </ul>
        </div>
    </div>
</@common.article>

<@common.article id="contribute" title="How to contribute?" titleRight="Featured users">
    <div class="left">
        <h3>Translation</h3>
        <p>Has the IPT user interface or documentation been translated into your native language yet? If not, we welcome new translations into any language. Instructions can be found <a href="https://github.com/gbif/ipt/wiki/HowToTranslate.wiki" title="Instructions on translating the IPT User Interface" target="_blank">here</a>.</p>
        <h3>Code</h3>
        <p>Is the IPT missing a key feature, or is the GBIF Secretariat too slow getting around to implementing an existing feature request or bug fix? Feel free to contribute a code patch yourself. To start, check out the latest version of the source code <a href="https://github.com/gbif/ipt" title="Link to download IPT source code from GitHub" target="_blank">here</a>.</p>
        <h3>Documentation</h3>
        <p>Is there a mistake in the IPT documentation? Perhaps some topic in the IPT wiki is missing? If so, please contact the <@common.helpdesk/> with your ideas, and we will grant you author privileges to the IPT wiki.</p>
    </div>
    <div class="right">
        <p>"Darwin Core Archives are required for data harvest to our new portal. We see IPT as a great tool to facilitate the creation of these files and to provide hosting of them for our participating institutions." - <em>Laura Russell, VertNet</em></p>
        <p>"Thanks to the IPT we now have a complete data mobilization workflow, from in-house data management systems to GBIF. The software tool has been instrumental in the growth of the Canadensys network." - <em>Peter Desmet, INBO &amp; Canadensys</em></p>
        <p>"The IPT has facilitated primary data publication for us. At SiB Colombia we use it as a central part of our <a href="http://www.sibcolombia.net/web/sib/acerca-del-sib" target="_blank">data publication model</a>" - <em>Danny Vélez, SiB Colombia</em></p>
    </div>
</@common.article>

</body>
</html>