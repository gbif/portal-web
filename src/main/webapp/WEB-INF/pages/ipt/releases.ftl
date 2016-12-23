<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
    <title>IPT</title>
</head>

<#assign tab="releases"/>
<#include "/WEB-INF/pages/ipt/inc/infoband.ftl" />


<body class="ipt">


<@common.article id="about" title="Latest release – version 2.3.3, December 2016" titleRight="Version history">
    <div class="left">
        <p>
            This version is intended to make the IPT even more robust and secure. The user interface has also been translated into Russian, extending its global reach even further.
        </p>
        <p>
            Additionally, please note that GBIF recently released a new set of Microsoft Excel templates for uploading data to the IPT. The new templates provide a simpler solution for capturing, formatting and uploading three types of GBIF data classes: <a href="https://github.com/gbif/ipt/wiki/samplingEventData#templates" title="Link to sampling-event data template" target="_blank">sampling-event data</a>, <a href="https://github.com/gbif/ipt/wiki/occurrenceData#templates" title="Link to occurrence data template" target="_blank">occurrence data</a>, and <a href="https://github.com/gbif/ipt/wiki/checklistData#templates" title="Link to checklist data template" target="_blank">checklist data</a>. More information about these templates can be found in <a href="http://www.gbif.org/newsroom/news/new-darwin-core-spreadsheet-templates" title="News article about new GBIF templates" target="_blank">this news article</a>.
        </p>
        <p>
        <h3><a href="http://repository.gbif.org/content/groups/gbif/org/gbif/ipt/2.3.3/ipt-2.3.3.war" title="Link to download IPT v2.3.3" onClick="ga('send', 'event', 'IPT_war', 'Download', 'IPT_2_3_3');">Download</a></h3>
        <h3><a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes23.wiki" title="IPT v2.3 Release notes" target="_blank">Release notes (upgrade instructions)</a></h3>
        </p>
        <p>&nbsp;</p>
        <h2>Roadmap - what's next?</h2>
        <p>
            No new major versions of the IPT have been planned at this time.
        </p>
        <p>
            As of December 23, 2016 there were
            <a href="https://github.com/gbif/ipt/issues"
               title="Link to open IPT issues"
               target="_blank">59 open issues</a>. Weigh in on existing issues with a "thumbs-up", or submit a new feature request for functionality you would like to see implemented.
        </p>
    </div>
    <div class="right">
        <h3><strong>2.3.3</strong> - December, 2016</h3>
        <ul>
            <li><a href="http://repository.gbif.org/content/groups/gbif/org/gbif/ipt/2.3.3/ipt-2.3.3.war" title="Dowload IPT v2.3.3" onClick="ga('send', 'event', 'IPT_war', 'Download', 'IPT_2_3_3');">Download</a> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes233.wiki" title="IPT v2.3.3 Release Notes" target="_blank">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPT2ManualNotes.wiki" title="IPT User Manual" target="_blank">User Manual</a> <a href="https://github.com/gbif/ipt/wiki/IPT2ManualNotes_ES.wiki" title="IPT User Manual Spanish" target="_blank">(es)</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/projects/1" title="IPT v2.3.3 Issues List" target="_blank">88 issues</a>: 22 Defects, 17 Enhancements, 36 Won’t fix, 10 Duplicates, and 3 Other
            </li>
            <li>Translated into 7 languages</li>
        </ul>
        <h3><strong>2.3</strong> - September, 2015</h3>
        <ul>
            <li><a href="http://repository.gbif.org/content/groups/gbif/org/gbif/ipt/2.3.2/ipt-2.3.2.war" title="Dowload IPT v2.3.2" onClick="ga('send', 'event', 'IPT_war', 'Download', 'IPT_2_3_2');"><strike>Download</strike></a> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes23.wiki" title="IPT v2.3 Release Notes" target="_blank">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPTUserManualv23.wiki" title="IPT v2.3 User Manual" target="_blank">User Manual</a> <a href="https://github.com/gbif/ipt/wiki/IPT2ManualNotes_ES.wiki" title="IPT User Manual Spanish" target="_blank">(es)</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/issues?q=is%3Aissue+label%3AMilestone-Release2.3" title="IPT v2.3 Issues List" target="_blank">38 issues</a>: 15 Defects, 15 Enhancements, 4 Won’t fix, and 4 that were considered as Tasks
            </li>
            <li>Translated into 6 languages</li>
        </ul>
        <h3><strong>2.2</strong> - March, 2015</h3>
        <ul>
            <li><a href="http://repository.gbif.org/content/groups/gbif/org/gbif/ipt/2.2.1/ipt-2.2.1.war" title="Dowload IPT v2.2" onClick="ga('send', 'event', 'IPT_war', 'Download', 'IPT_2_2_1');"><strike>Download</strike></a> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes22.wiki" title="IPT v2.2 Release Notes" target="_blank">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPTUserManualv22.wiki" title="IPT v2.2 User Manual" target="_blank">User Manual</a> <a href="https://github.com/gbif/ipt/wiki/IPT2ManualNotes_ES.wiki" title="IPT User Manual Spanish" target="_blank">(es)</a></li>
            <li><a href="http://gbif.blogspot.com/2015/03/ipt-v22.html" title="IPT v2.2 Release Announcement" target="_blank">Release Announcement</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/issues?q=label%3AMilestone-Release2.2" title="IPT v2.2 Issues List" target="_blank">74 issues</a>: 20 Defects, 26 Enhancements, 16 Won’t fix, 6 Duplicates, 2 Other, 1 Task, and 3 that were considered as Invalid
            </li>
            <li>Translated into 6 languages</li>
        </ul>
        <h3><strong>2.1</strong> - April, 2014</h3>
        <ul>
            <li><a href="http://repository.gbif.org/content/groups/gbif/org/gbif/ipt/2.1.1/ipt-2.1.1.war" title="Dowload IPT v2.1.1" onClick="ga('send', 'event', 'IPT_war', 'Download', 'IPT_2_1_1');"><strike>Download</strike></a> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes21.wiki" title="IPT v2.1 Release Notes" target="_blank">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPTUserManualv21.wiki" title="IPT v2.1 User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/archive/p/gbif-providertoolkit/wikis/IPTUserManualv21.wiki" title="IPT v2.1 User Manual Spanish" target="_blank">(es)</a></li>
            <li><a href="http://gbif.blogspot.dk/2014/04/ipt-v21.html" title="IPT v2.1 Release Announcement" target="_blank">Release Announcement</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/issues?q=label%3AMilestone-Release2.1" title="IPT v2.1 Issues List" target="_blank">85 issues</a>: 38 Defects, 11 Enhancements, 18 Won’t fix, 6 Duplicates, 1 Other, and 11 that were considered as Invalid
            </li>
            <li>Translated into 6 languages (Japanese translation added)</li>
        </ul>
        <h3><strong>2.0.5</strong> - May, 2013</h3>
        <ul>
            <li><strike>Download</strike> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes205.wiki" title="IPT v2.0.5 Release Notes" target="_blank">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPTUserManualv205.wiki" title="IPT v2.0.5 User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv205?wl=es" title="IPT v2.0.5 User Manual Spanish" target="_blank">(es)</a></li>
            <li><a href="http://gbif.blogspot.dk/2013/05/ipt-v205-released-melhor-versao-ate-o.html" title="IPT v2.0.5 Release Announcement" target="_blank">Release Announcement</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/issues?q=label%3AMilestone-Release2.0.5" title="IPT v2.0.5 Issues List" target="_blank">45 issues</a>: 15 Defects, 17 Enhancements, 2 Patches, 7 Won’t fix, 3 Duplicates, and 1 that was considered as Invalid
            </li>
            <li>Translated into 5 languages (Portuguese translation added)</li>
        </ul>
        <h3><strong>2.0.4</strong> - October, 2012</h3>
        <ul>
            <li><strike>Download</strike> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes204.wiki" title="IPT v2.0.4 Release Notes">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPTUserManualv204.wiki" title="IPT v2.0.4 User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv204?wl=es" title="IPT v2.0.4 User Manual Spanish" target="_blank">(es)</a></li>
            <li><a href="http://gbif.blogspot.dk/2012/10/ipt-v204-released.html" title="IPT v2.0.4 Release Announcement" target="_blank">Release Announcement</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/issues?q=label%3AMilestone-Release2.0.4" title="IPT v2.0.4 Issues List" target="_blank">108 issues</a>: 38 Defects, 35 Enhancements, 7 Other, 5 Patches, 18 Won't fix, 4 Duplicates, and 1 that was considered as Invalid
            </li>
            <li>Translated into 4 languages (Traditional Chinese translation added)</li>
        </ul>
        <h3><strong>2.0.3</strong> - November, 2011</h3>
        <ul>
            <li><strike>Download</strike> / <a href="https://github.com/gbif/ipt/wiki/IPTReleaseNotes203.wiki" title="IPT v2.0.3 Release Notes">Notes</a></li>
            <li><a href="https://github.com/gbif/ipt/wiki/IPTUserManualv203.wiki" title="IPT v2.0.3 User Manual" target="_blank">User Manual</a> <a href="https://code.google.com/p/gbif-providertoolkit/wiki/IPTUserManualv203?wl=es" title="IPT v2.0.3 User Manual Spanish" target="_blank">(es)</a></li>
            <li><a href="http://gbif.blogspot.dk/2011/11/important-quality-boost-for-gbif-data.html" title="IPT v2.0.3 Release Announcement" target="_blank">Release Announcement</a></li>
            <li>Addressed <a href="https://github.com/gbif/ipt/issues?q=label%3AMilestone-Release2.0.3" title="IPT v2.0.3 Issues List" target="_blank">85 issues</a>: 43 defects, 31 enhancements, 3 Patches, 7 Won’t fix, and 1 Duplicate
            </li>
            <li>Translated into 3 languages (French and Spanish translations added)</li>
        </ul>
    </div>
</@common.article>

</body>
</html>