<content tag="infoband">
    <h1>Infrastructure</h1>
   	<h3>How GBIF works as a global informatics infrastructure</h3>
</content>

<content tag="tabs">
  <ul>
    <li<#if (tab!"")=="summary"> class='selected'</#if>><a href="<@s.url value='/infrastructure'/>" ><span>Summary</span></a></li>
    <li<#if (tab!"")=="registry"> class='selected'</#if>><a href="<@s.url value='/infrastructure/registry'/>" ><span>Registry</span></a></li>
    <li<#if (tab!"")=="occurrences"> class='selected'</#if>><a href="<@s.url value='/infrastructure/occurrences'/>" ><span>Occurrences</span></a></li>
    <#-- <li<#if (tab!"")=="names"> class='selected'</#if>><a href="<@s.url value='/infrastructure/names'/>" ><span>Names</span></a></li> -->
    <li<#if (tab!"")=="tools"> class='selected'</#if>><a href="<@s.url value='/infrastructure/tools'/>" ><span>Tools</span></a></li>
  </ul>
</content>
