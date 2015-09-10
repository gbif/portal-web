<content tag="infoband">
    <h1>Integrated Publishing Toolkit (IPT)</h1>
    <h3>A GBIF tool to enable the publishing of biodiversity datasets</h3>

    <div class="box">
        <div class="content">
            <ul>
                <li class="single last"><h4>v2.3</h4>(Latest version)</li>
            </ul>
            <a href="<@s.url value='http://repository.gbif.org/content/groups/gbif/org/gbif/ipt/2.3/ipt-2.3.war'/>" title="Download latest version of IPT" class="candy_blue_button" onClick="ga('send', 'event', 'IPT_war', 'Download', 'IPT_2_3');"><span>Download</span></a>
        </div>
    </div>
</content>

<content tag="tabs">
    <ul>
        <li<#if (tab!"")==""> class='selected'</#if>><a href="<@s.url value='/ipt'/>" ><span>Summary</span></a></li>
        <li<#if (tab!"")=="stats"> class='selected'</#if>><a href="<@s.url value='/ipt/stats'/>" ><span>Stats</span></a></li>
        <li<#if (tab!"")=="releases"> class='selected'</#if>><a href="<@s.url value='/ipt/releases'/>" ><span>Releases</span></a></li>
    </ul>
</content>
