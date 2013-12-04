<#import "/WEB-INF/macros/common.ftl" as common>
<#--
Macro for rendering pagination on the web app. 
If the page.count exists, it renders a numbered pagination.
If the page.count does not exist (is null), it renders the simple pagination (without numbered pages) 
 - page: a mandatory PagingResponse instance
 - url: mandatory, current url without paging parameters
-->
<#macro pagination page url maxOffset=-1>
  <#if page.offset gt 0 || !page.isEndOfRecords()>
    <#if page.count??>
      <#-- do not show pagination at all if count is less or equal to the total limit -->
      <#if (page.count > page.limit)>
        <@numberedPagination page url maxOffset/>
      </#if>
    <#else>
      <@simplepagination page url/>
    </#if>
  </#if>
</#macro>





<#-- 
Pagination macro for rendering NEXT & PREVIOUS buttons, whenever applicable 
 - offset: mandatory, current offset
 - limit: mandatory, maximum number of records to display per page
 - totalResults: optional, total number of records. If this parameter is not set,
                 then the NEXT button will always be displayed and the 
                 "viewing page X of Y (total)" message will not be displayed.
 - page: a mandatory PagingResponse instance
 - url: mandatory, current url
 
 Please feel free to improve the code in any way.
-->
<#macro simplepagination page url numNumbered=4>
  <#-- the current page number, first page = 1 -->
  <#assign currPage = (page.offset/page.limit)?round + 1 />
  <#-- the first numbered page to show. If only 1 page exists its a special case caught below -->
  <#assign firstNum = common.max(2, currPage - numNumbered +1) />

  <ul class="numbered-pagination">
    <@pageLink title="First" url=getPageUrl(url, 0) current=(currPage=1) />
    <#if !page.isEndOfRecords()>
      <#if currPage gt 1>
        <#if currPage-numNumbered gt 1>
          <li>...</li>
        </#if>
        <#list firstNum .. currPage as p>
          <@pageLink title=p url=getPageUrl(url, page.limit*(p-1)) current=(currPage=p) />
        </#list>
      </#if>
      <@pageLink title="Next" url=getPageUrl(url, page.limit*(currPage)) current=false />
    </#if>
  </ul>
</#macro>




<#-- 
Pagination macro for rendering numbered page links as well as [FIRST PAGE] and [LAST PAGE] links. 
 - page: a mandatory PagingResponse instance
 - url: mandatory, current url
 - maxPages: optional, number of page links to show at max without counting first & last, defaults to 5

 The macro result will look like this (links are not important for documentation purposes, so they have been replaced by a '#'):
 
  <ul class="numbered-pagination">
    <li><a href="#">First</a></li>
    <li><a class="current" href="#">2</a></li>
    <li><a href="#">3</a></li>
    <li><a href="#">4</a></li>
    <li><a href="#">5</a></li>
    <li><a href="#">6</a></li>
    <li><a href="#">Last</a></li>
  </ul>
 -->
<#macro numberedPagination page url maxOffset=-1 maxLink=5>
  <#-- New maximum offset is calculated -->
  <#if maxOffset != -1 && page.count gt maxOffset>
    <#assign count = maxOffset/>
  <#else>
    <#assign count = page.count/>
  </#if>
  
  <#if maxOffset != -1 && page.offset gt (maxOffset - page.limit)>    
    <#assign offset = maxOffset - page.limit/>
  <#else>
    <#assign offset = page.offset/>
  </#if>
  
  <#-- Total number of pages for the resultset -->
  <#assign totalPages = (count/page.limit)?ceiling />
  <#-- the current page number, first page = 1 -->
  <#assign currPage = (offset/page.limit)?round + 1 />
  <#-- the first numbered page to show. If only 1 page exists its a special case caught below -->
  <#assign minPage = common.max(currPage - (maxLink/2)?floor, 2) />
  <#-- the last numbered page to show -->
  <#assign maxPage = common.max(minPage, common.min(minPage + maxLink - 1, totalPages - 1))/>

  <ul class="numbered-pagination">
  <@pageLink title="First" url=getPageUrl(url, 0) current=(currPage=1) />
  <#if totalPages gt 1 >
    <#if totalPages gt 2 >
      <#list minPage .. maxPage as p>
        <@pageLink title=p url=getPageUrl(url, page.limit*(p-1)) current=(currPage=p) />
      </#list>
      <#if totalPages gt maxPage + 1>
        <li>...</li>
      </#if>
    </#if>
    <@pageLink title="Last" url=getPageUrl(url, page.limit*(totalPages-1)) current=(currPage=totalPages) />
  </#if>
  </ul>
</#macro>

<#macro pageLink title url current=false>
<li><a <#if current>class="current"</#if> href="${url}">${title?string}</a></li>
</#macro>




<#-- 
	Returns the current page number a user is navigating.
-->
<#function getCurrentPage offset limit start=1 current=1>
    <#if (offset<start)>
  		<#return current>
	<#else>
		${getCurrentPage(offset,limit,(start+limit), current+1)}
	</#if>
</#function>


<#--
	Appends the "offset" query parameters to an existing URL assuming the limit is static and defined by the action alone.
	If there existing query parameters, the append is done using an ampersand (&).
	If there are no existing query parameters, the append is done using the (?).
-->
<#function getPageUrl url offset>
	<#assign fullUrl = "" >
		<#if url?contains("?")>
			<#assign fullUrl = url + "&offset=" + offset?c >
		<#else>
			<#assign fullUrl = url + "?offset=" + offset?c >
		</#if>
	<#return fullUrl>	
</#function>
