<content tag="infoband">
    <h1>Integrated Publishing Toolkit (IPT)</h1>
   	<h3>A GBIF tool to enable the publishing of biodiversity datasets</h3>

    <div class="box">
        <div class="content">
            <ul>
                <li class="single last"><h4>v2.0.5</h4>(Latest version)</li>
            </ul>
            <a href="<@s.url value='https://gbif-providertoolkit.googlecode.com/files/ipt-2.0.5-security-update-1.war'/>" title="View occurrences" class="candy_blue_button"><span>Download</span></a>
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
