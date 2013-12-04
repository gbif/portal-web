<#assign taiwanNodeKey='e1b85abc-61f9-430f-ba79-6813dec53a0f' />
<#assign tempNodeKey='02c40d2a-1cba-4633-90b7-e36e5e97aba8' />
<#assign colKey='7ddf754f-d193-4cc9-b351-99906754a03b' />
<#assign uknbnOrganizationKey='07f617d0-c688-11d8-bf62-b8a03c50a862' />
<#assign iptInstallationType='IPT_INSTALLATION' />
<#assign digirInstallationType='DIGIR_INSTALLATION' />
<#assign tapirInstallationType='TAPIR_INSTALLATION' />
<#assign biocaseInstallationType='BIOCASE_INSTALLATION' />
<#assign httpInstallationType='HTTP_INSTALLATION' />


<!-- maximum function -->
<#function max x y>
    <#if (x<y)><#return y><#else><#return x></#if>
</#function>
<!-- minimum function -->
<#function min x y>
    <#if (x<y)><#return x><#else><#return y></#if>
</#function>
<#--
	Limits a string to a maximun length and adds an ellipsis if longer.
-->
<#function limit x max=100>
  <#assign x=(x!"")?trim/>
  <#if ((x)?length <= max)>
    <#return x>
    <#else>
      <#return x?substring(0, max)+"…" />
  </#if>
</#function>

<#--
	Creates a multiline paragraph by replaces any of \n, \n or \n\r with an html <br/> line break.
-->
<#function para x>
  <#return x?replace("\r\n", "<br/>")?replace("\r", "<br/>")?replace("\n", "<br/>") />
</#function>

<#--
  Truncates the string if too long and adds a more link
-->
<#macro limitWithLink text max link>
  <#assign text = text!""/>
  <#assign text = text?trim/>
  <#if (text?length <= max)>
    ${text}
    <#else>
    ${text?substring(0, max)}… <a class="more" href='${link}'>more</a>
  </#if>
</#macro>

<#macro usageSource component showChecklistSource=false showChecklistSourceOnly=false>
  <#if showChecklistSourceOnly>
    <#assign source=""/>
    <#else>
      <#assign source=(component.source!"")?trim/>
  </#if>
  <#if showChecklistSource>
    <#assign source><a href='<@s.url value='/species/${component.usageKey?c}'/>'>${(datasets.get(component.datasetKey).title)!"???"}</a><br/>${source}</#assign>
  </#if>
  <#if source?has_content || component.remarks?has_content>
  <a class="sourcePopup" data-message="${source!}" data-remarks="${component.remarks!}"></a>
  </#if>
</#macro>

<#macro usageSources components popoverTitle="Sources" showSource=true showChecklistSource=true>
  <#assign source>
    <#list components as comp>
      <p>
        <#if showSource>${comp.source!""}</#if>
        <#if showSource && showChecklistSource><br/></#if>
        <#if showChecklistSource><a href='<@s.url value='/species/${comp.usageKey?c}'/>'>${(datasets.get(comp.datasetKey).title)!"???"}</a></#if>
      </p><br/>
    </#list>
  </#assign>
  <a class="sourcePopup" title="${popoverTitle}" data-message="${source!}" data-remarks=""></a>
</#macro>

<#macro popup message remarks="" title="Source">
  <#if message?has_content>
  <a class="sourcePopup" title="${title}" data-message="${message}" data-remarks="${remarks!}"></a>
  </#if>
</#macro>

<#--
  a popup help along the lines of this:
  http://dev.gbif.org/issues/secure/attachment/11424/gbif_help_links.png 
-->
<#macro explanation message label remarks="" title="Help">
  <#if message?has_content>
    <a class="helpPopup" title="${title}" data-message="${message}" data-remarks="${remarks!}">${label}</a>
  </#if>
</#macro>

<#macro popover linkTitle popoverTitle>
  <a class="popover" title="${popoverTitle}" data-remarks="">${linkTitle}</a>
  <div class="message"><#nested></div>
</#macro>


<#-- Creates just an address block for a given WritableMember or Contact instance -->
<#macro address address >
<div class="address">
  <#if address.address?has_content>
    <span>${para(address.address)}</span>
  </#if>

  <#if address.postalCode?has_content || address.zip?has_content || address.city?has_content>
    <span class="city">
    <#-- members use zip, but Contact postalCode -->
    <#if address.postalCode?has_content || address.zip?has_content>
      ${address.postalCode!address.zip}
    </#if>
    ${address.city!}
    </span>
  </#if>

  <#if address.province?has_content>
    <span class="province">${address.province}</span>
  </#if>

  <#if address.country?has_content && address.country != 'UNKNOWN'>
    <span class="country">${address.country.title}</span>
  </#if>

  <#if address.email?has_content>
      <span class="email"><a href="mailto:${address.email}" title="email">${address.email}</a></span>
  </#if>

  <#if address.phone?has_content>
    <span class="phone">${address.phone}</span>
  </#if>

</div>
</#macro>


<#--
	Construct a Contact. Parameter is the actual contact object.
-->
<#macro contact con>
<div class="contact">
  <#if con.key??>
    <a name="contact${con.key?c!}"></a>
  </#if>
  <#if con.type?has_content>
   <div class="contactType">
    <#if con.type?has_content>
      <@s.text name="enum.contacttype.${con.type}"/>
    </#if>
   </div>
  </#if>
   <div class="contactName">
    ${con.firstName!} ${con.lastName!}
   </div>
  <#-- we use this div to toggle the grouped information -->
  <div>
    <#if con.position?has_content>
     <div class="contactPosition">
      ${con.position!}
     </div>
    </#if>
    <#if con.organization?has_content>
     <div class="contactInstitution">
       ${con.organization!}
     </div>
    </#if>
    <@address address=con />
  </div>
</div>
</#macro>

<#-- Creates a column list of contacts, defaults to 2 columns -->
<#macro contactList contacts title="" columns=2 showAllButton=false>
  <#if title?has_content>
    <h3>${title}</h3>
  </#if>
  <#list contacts as c>
 <#if c_index%columns==0>
  <div class="row col${columns}">
 </#if>
 <@contact con=c />
 <#if c_index%columns==columns-1 || !c_has_next >
  <!-- end of row -->
  </div>
 </#if>
</#list>
<#if showAllButton>
  <div class="row col${columns}">
    <span class="showAllContacts small">show all</span>
  </div>
<#else>
  <#-- needed to terminate contact block, e.g. where primary contacts and other contacts are separated in 2 blocks on publisher page -->
  <div class="row"></div>
</#if>
</#macro>

<#--
	Construct a Endpoint. Parameter is the actual endpoint object.
-->
<#macro endpoint ep>
<p>
  <b><h4>${ep.type}</h4></b>
  <#if ep.url?has_content>
  ${ep.url!}
  </#if>
</p>
</#macro>

<#--
	Construct a Identifier. Parameter is the actual identifier object.
-->
<#macro identifier i>
<p>
  <b><h4>${i.type}</h4></b>
  <#if i.identifier?has_content>
  ${i.identifier!}
  </#if>
</p>
</#macro>

<#macro citation c>
  ${c.text!}
  <#if c.identifier?has_content>
    <#if c.text?has_content>,</#if> <a href="${c.identifier}">${c.identifier}</a>
  </#if>
</#macro>

<#macro citationArticle rights dataset publisher prefix="">
  <@common.article id="legal" title="Citation and licensing" class="mono_line">
  <div class="fullwidth">
    <#if dataset.citation?? && !dataset.citation.text!?ends_with(dataset.title)>
      <p>The content  of the "Dataset citation provided by the publisher" depends on the metadata supplied by the publisher.
         In some cases this may be incomplete.  A standard default form for citing is provided as an alternative.
         We are in transition towards providing more consistent citation text for all datasets.
      </p>

      <h3>Dataset citation provided by publisher</h3>
      <p>${dataset.citation.text}</p>
    </#if>

    <h3>Default citation</h3>
    <p>${prefix!}<#if publisher??>${publisher.title}:</#if>
      ${dataset.title}<#if dataset.pubDate?has_content>, ${dataset.pubDate?date?iso_utc}</#if>.
      <br/>Accessed via ${currentUrl} on ${.now?date?iso_utc}
    </p>

    <#if rights?has_content>
      <h3>Rights</h3>
      <p>${rights}</p>
    </#if>

  </div>
  </@common.article>
</#macro>


<#macro enumParagraph enum>
  <p><#if enum.interpreted?has_content>${enum.interpreted?string}<#else>${enum.verbatim!"&nbsp;"}</#if></p>
</#macro>

<#macro article id="" title="" titleRight="" fullWidthTitle=false class="">
<article<#if id?has_content> id="${id}"</#if> class="${class!}">
  <header></header>
  <#if id?has_content>
    <a name="${id}"></a>
  </#if>
  <div class="content">
    <div class="header">
      <#if title?has_content>
        <div <#if !fullWidthTitle> class="left"</#if>>
          <h2>${title}</h2>
        </div>
      </#if>
      <#if titleRight?has_content>
        <div class="right">
          <h2>${titleRight}</h2>
        </div>
      </#if>
    </div>
    <#nested>
  </div>
  <footer></footer>
</article>
</#macro>

<#macro notice title>
<article class="notice">
  <header></header>
  <div class="content">
    <img id="notice_icon" src="<@s.url value='/img/icons/notice_icon.png'/>" />
    <h3>${title!}</h3>
    <#nested>
  </div>
  <footer></footer>
</article>
</#macro>

<#-- write "from city, country" or "from country" under the condition that country must always be present in both cases -->
<#macro cityAndCountry member>
  <#if member.country??>
    <#if member.country?lower_case != "unknown">
    from
      <#if member.city??>
        <#if member.city?has_content>${member.city}<#if member.country?has_content>, </#if></#if>
      </#if>
      ${member.country.title}
    </#if>
  </#if>
</#macro>

<#macro renderNomStatusList nomStatusList>
  <#list nomStatusList as ns><#if ns.abbreviated?has_content>${ns.abbreviated}<#else>${ns?replace("_", " ")?lower_case}</#if><#if ns_has_next>, </#if></#list>
</#macro>

<#-- writes a standard list item for a dataset for display across country, node, network, installation, dataset and publisher pages -->
<#macro datasetListItem title key type modified owningOrganizationKey="" owningOrganizationTitle="" count=0 geoCount=0 >
  <li>
    <a title="${title}" href="<@s.url value='/dataset/${key}'/>">${common.limit(title, 100)}</a>
    <span class="note">${type?lower_case?cap_first} dataset. <#if modified?has_content>Updated ${modified?date}.</#if> <#if (count &gt; 0)>${count} records <#if geoCount &gt; 0>(${geoCount} georeferenced)</#if></#if> <#if owningOrganizationKey?has_content && owningOrganizationTitle?has_content> Published by <a href="<@s.url value='/publisher/${owningOrganizationKey}'/>" title="${owningOrganizationTitle}">${owningOrganizationTitle}</a></#if></span>
  </li>
</#macro>