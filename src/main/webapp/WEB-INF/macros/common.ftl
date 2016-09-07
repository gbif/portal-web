<#assign taiwanNodeKey='e1b85abc-61f9-430f-ba79-6813dec53a0f' />
<#assign tempNodeKey='02c40d2a-1cba-4633-90b7-e36e5e97aba8' />
<#-- The participant node managers committee is treated as a psuedo node in the registry -->
<#assign participantNMCKey='7f48e0c8-5c96-49ec-b972-30748e339115' />
<#assign colKey='7ddf754f-d193-4cc9-b351-99906754a03b' />
<#assign nubKey='d7dddbf4-2cf0-4f39-9b2a-bb099caae36c' />
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
      <#return x?substring(0, max-1)+"…" />
  </#if>
</#function>

<#--
	Creates a multiline paragraph by replaces any of \n, \n or \n\r with an html <br/> line break.
-->
<#function para x>
  <#return x?replace("\r\n", "<br/>")?replace("\r", "<br/>")?replace("\n", "<br/>") />
</#function>

<#function enumLabel x>
  <#return x.name()?replace("_"," ")?lower_case?cap_first />
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


<#-- Creates just an address block for a given Node or Contact instance implementing our Address interface-->
<#macro address adr>
<div class="address">
  <#if adr.organization?has_content>
    <span>${adr.organization}</span>
  <#--
    See whether span or div is better !!!
    <div class="contactInstitution">
    ${adr.organization!}
    </div>
  -->
  </#if>

  <#if adr.address?has_content>
    <span><#list adr.address as a>${a!}<#if a_has_next><br/></#if></#list></span>
  </#if>

  <#if adr.postalCode?has_content || adr.zip?has_content || adr.city?has_content>
    <span class="city">
    <#-- members use zip, but Contact postalCode -->
    <#if adr.postalCode?has_content || adr.zip?has_content>
      ${adr.postalCode!adr.zip}
    </#if>
    ${adr.city!}
    </span>
  </#if>

  <#if adr.province?has_content>
    <span class="province">${adr.province}</span>
  </#if>

  <#if adr.country?has_content && adr.country != 'UNKNOWN'>
    <span class="country">${adr.country.title}</span>
  </#if>

  <#if adr.email?has_content>
    <#list adr.email as email>
      <#if email?has_content>
        <span class="email"><a href="mailto:${email}" title="email">${email}</a></span>
      </#if>
    </#list>
  </#if>

  <#if adr.phone?has_content>
    <#list adr.phone as phone>
     <#if phone?has_content>
      <span class="phone">${phone}</span>
     </#if>
    </#list>
  </#if>

  <#if adr.userId?has_content>
    <#list adr.userId as id>
    <span class="email"><a href="${id!}" title="userID-${id_index}">${id!}</a>
      <#if id_has_next><br/></#if>
    </#list>
  </span>
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
      <#list con.position as p>${p!}<#if p_has_next>, </#if></#list>
     </div>
    </#if>
    <@address adr=con />
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


<#-- Creates a multi column list of some items -->
<#macro multiColList items columns=2>
  <#assign maxRows=items?size / columns />
  <#list 1..columns as col>
  <div class="col">
    <ul class="notes">
    <#list items as i>
      <#if (i_index < maxRows * col) && (i_index >= maxRows*(col-1))>
        <li>${i}</li>
      </#if>
    </#list>
    </ul>
  </div>
  </#list>
</#macro>


<#-- produces a full contact block -->
<#macro contactArticle primaryContacts otherContacts columns=3 showAllButton=false>
  <#if otherContacts?has_content >
    <@article id="other_contacts" title="Other Contacts">
    <div class="fullwidth">
      <#if otherContacts?has_content >
        <@contactList contacts=otherContacts columns=3/>
      </#if>
    </div>
    </@article>
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

<#macro licenseIcon license>
<span class="cc-icons">
  <img src="<@s.url value='/img/cc-icons/cc.png'/>" />
  <#if license == 'CC0_1_0'>
    <img src="<@s.url value='/img/cc-icons/zero.png'/>" />
  <#elseif license == 'PDM'>
    <img src="<@s.url value='/img/cc-icons/pd.png'/>" />
  <#elseif license == 'CC_BY_4_0'>
    <img src="<@s.url value='/img/cc-icons/by.png'/>" />
  <#elseif license == 'CC_BY_NC_4_0'>
    <img src="<@s.url value='/img/cc-icons/by.png'/>" />
    <img src="<@s.url value='/img/cc-icons/nc.png'/>" />
  </#if>
</span>
</#macro>

<#macro license license>
${dataset.license.licenseTitle}
<a rel="license" href="${dataset.license.licenseUrl}" title="${dataset.license.licenseTitle}"><@licenseIcon license /></a>
</#macro>

<#macro citationArticle rights dataset publisher prefix="">
  <@article id="legal" title="Citation and licensing" class="mono_line">
  <div class="fullwidth">
    <#if dataset.citation??>
      <p>The content  of the "Dataset citation provided by the publisher" depends on the metadata supplied by the publisher.
         In some cases this may be incomplete.  A standard default form for citing is provided as an alternative.
         We are in transition towards providing more consistent citation text for all datasets.
      </p>

      <h3>Dataset citation provided by publisher</h3>
      <p>${dataset.citation.text}</p>
    </#if>

    <h3>Default citation</h3>
    <p>${prefix!}<#if publisher??>${publisher.title}:</#if>
      ${dataset.title}. <#if dataset.doi??><@doilink dataset.doi /></#if>
      <br/>Accessed via ${currentUrl} on ${.now?date?iso_utc}
    </p>

    <#if dataset.license?has_content && dataset.license != "UNSPECIFIED" && dataset.license != "UNSUPPORTED">
      <h3>License</h3>
      <p><@license license=dataset.license /></p>
    <#elseif rights?has_content>
      <h3>Rights</h3>
      <p>${rights}</p>
    </#if>

  </div>
  </@article>
</#macro>

<#-- Creates a dt dd definition if the value has content, otherwise none -->
<#macro definition title value>
 <#if value?has_content>
  <dt>${title}</dt>
   <#if value?starts_with("http")>
     <dd><a href="${value}" title="${value}">${limit(value, 34)}</a></dd>
   <#else>
     <dd>${value}</dd>
   </#if>
 </#if>
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

<#macro notice title id="" sessionBound=false>
<article <#if id?has_content>id="${id}"</#if> class="notice<#if sessionBound> sessionBound</#if>">
  <header></header>
  <div class="content">
    <img src="<@s.url value='/img/icons/notice_icon.png'/>" />
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
<#macro datasetListItem title key type modified publishingOrganizationKey="" publishingOrganizationTitle="" count=0 geoCount=0 >
  <li>
    <a title="${title}" href="<@s.url value='/dataset/${key}'/>">${common.limit(title, 100)}</a>
    <span class="note">${type?lower_case?cap_first} dataset. <#if modified?has_content>Updated ${modified?date}.</#if> <#if (count &gt; 0)>${count} records <#if geoCount &gt; 0>(${geoCount} georeferenced)</#if></#if> <#if publishingOrganizationKey?has_content && publishingOrganizationTitle?has_content> Published by <a href="<@s.url value='/publisher/${publishingOrganizationKey}'/>" title="${publishingOrganizationTitle}">${publishingOrganizationTitle}</a></#if></span>
  </li>
</#macro>

<#-- writes a standard, styled DOI link taking a doi instance-->
<#macro doi doi url="">
<span class="doi"><@doilink doi url/></span>
</#macro>

<#-- writes an unstyled DOI link taking a doi instance and an optional url-->
<#macro doilink doi url="">
<a href="<#if url?has_content><@s.url value='${url}'/><#else>${doi.getUrl()}</#if>">${doi}</a>
</#macro>


<#-- writes an html anchor link to the GBIF helpdesk-->
<#macro helpdesk>
<a href="mailto:helpdesk@gbif.org" title="GBIF Helpdesk Email">GBIF Helpdesk</a>
</#macro>

<#-- writes a download citation text -->
<#macro citeDownload download>
GBIF.org (${niceDate(download.created)}) GBIF Occurrence Download <a href="${download.doi.getUrl()}">${download.doi.getUrl()}</a>
</#macro>

<#--
	Construct a Endpoint. Parameter is the actual endpoint object.
-->
<#macro showIfDifferent master copy>
<#compress>
<#if (master!"")?trim?replace(" ","")?lower_case != (copy!"")?trim?replace(" ","")?lower_case>${copy!}</#if>
</#compress>
</#macro>