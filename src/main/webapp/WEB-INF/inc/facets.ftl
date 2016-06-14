<#import "/WEB-INF/macros/common.ftl" as common>
<#--
This include requires 2 arrays to be set:
 facets: list of facet names just as the SearchParameter enums provide
 seeAllFacets: list of optional facets to always show completely, never via a popup
-->
<#macro facetBox facetName count selected=false>
  <#assign cntstr = "" + (count.count!minCnt) />
  <#assign maxlen = 28 - cntstr?length />
<li>
  <input type="checkbox" value="${facetName?lower_case}=${count.name!}" <#if selected>checked</#if> />
  <a href="#" title="${maxlen} - ${count.title!"Unknown"}">${common.limit( count.title!"Unknown" ,maxlen)}</a> (${count.count!minCnt})
</li>
</#macro>
<#list facets as facetName>
  <#assign facet = action.getSearchParam(facetName)>
  <#assign minCnt = "&lt;" + (facetMinimumCount.get(facet)!0) />
  <#assign displayedFacets = 0>
  <#assign seeAll = false>
  <#assign isPageableFacet = false>

    <#if action.isFacetPagingInRequest(facet) || (facetCounts.get(facet)?has_content && (selectedFacetCounts.get(facet)?has_content || facetCounts.get(facet)?size > 0))>
     <div class="refine">
      <h4><@s.text name="search.facet.${facetName}" /></h4>
      <div class="facet">
        <ul id="facetfilter${facetName}">
        <#if selectedFacetCounts.get(facet)?has_content>
          <#list selectedFacetCounts.get(facet) as count>
            <#assign displayedFacets = displayedFacets + 1>
            <@facetBox facetName=facetName count=count selected=true />
          </#list>
        </#if>
        <#if facetCounts?has_content>
          <#list facetCounts.get(facet) as count>
            <#if seeAllFacets?seq_contains(facetName) && (displayedFacets > MaxFacets)>
              <#assign seeAll=true>
              <#break>
            </#if>
            <#if !(action.isInFilter(facet,count.name))>
              <#assign displayedFacets = displayedFacets + 1>
              <@facetBox facetName=facetName count=count selected=false />
            </#if>
          </#list>
        </#if>
        <#assign isPageableFacet=pageableFacets?seq_contains(facetName) && action.showFacetPaging(facet)>
        <#if seeAll && facetCounts?has_content>
          <li class="more seeAllFacet">
            <a class="seeAllLink more" href="#">more</a>
            <div class="infowindow dialogPopover">
                <div class="lheader"></div>
                <span class="close"></span>
                <div class="content">
                  <h2>Filter by <@s.text name="search.facet.${facetName}" /></h2>

                 <div class="scrollpane">
                   <ul>
                    <#list facetCounts.get(facet) as count>
                      <@facetBox facetName=facetName count=count selected=action.isInFilter(facet,count.name) />
                    </#list>
                   </ul>
                 </div>

               </div>
               <div class="lfooter"><#if isPageableFacet><@macro.facetpagination facet=facetName url=action.getFacetPageCurrentUrl(facetName)/></#if>
               </div>
             </div>
          </li>
        </#if>
        <#if isPageableFacet><@macro.facetpagination facet=facetName url=action.getFacetPageCurrentUrl(facetName) showbox=false/></#if>
        </ul>
      </div>
     </div>
    </#if>
</#list>
