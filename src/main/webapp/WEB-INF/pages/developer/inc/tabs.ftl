<content tag="infoband">
    <h1>${(tab!"webservice")?capitalize} API</h1>
    <h3>version v0.9</h3>
</content>

<content tag="tabs">
  <ul>
    <li<#if (tab!"")==""> class='selected'</#if>><a href="<@s.url value='/developer/summary'/>" ><span>Summary</span></a></li>
    <li<#if (tab!"")=="registry"> class='selected'</#if>><a href="<@s.url value='/developer/registry'/>" ><span>Registry</span></a></li>
    <li<#if (tab!"")=="species"> class='selected'</#if>><a href="<@s.url value='/developer/species'/>" ><span>Species</span></a></li>
    <li<#if (tab!"")=="occurrence"> class='selected'</#if>><a href="<@s.url value='/developer/occurrence'/>" ><span>Occurrence</span></a></li>
    <li<#if (tab!"")=="maps"> class='selected'</#if>><a href="<@s.url value='/developer/maps'/>" ><span>Maps</span></a></li>
    <li<#if (tab!"")=="news"> class='selected'</#if>><a href="<@s.url value='/developer/news'/>" ><span>News Feeds</span></a></li>
  </ul>
</content>
