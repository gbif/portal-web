<#import "/WEB-INF/macros/common.ftl" as common>

<#--
	Construct a Dataset record.
	WARNING! if showPublisher is true an action method action.getOrganization(UUID) must exist to return the matching org
-->
<#macro dataset dataset maxDescriptionLength=500 showPublisher=false>
  <div class="result">
    <h3>${dataset.subtype!} <@s.text name="enum.datasettype.${dataset.type!}"/></h3>
    <h2>
      <strong>

      <#-- dataset name and hyperlinked to its corresponding page -->
      <#if dataset.title?has_content>
        <a href="<@s.url value='/dataset/${dataset.key}'/>">${dataset.title}</a>
      </#if>

      </strong>
    </h2>

    <#if showPublisher && dataset.publishingOrganizationKey??>
      <p>
        <#assign publisher=action.getOrganization(dataset.publishingOrganizationKey) />
        Published by <a href="<@s.url value='/publisher/${publisher.key}'/>" title="${publisher.title}">${publisher.title}</a>.
      </p>
    </#if>

    <div class="footer">
      <#if dataset.description?has_content>
        <p class="note semi_bottom">${common.limit(dataset.description, maxDescriptionLength)}</p>
      </#if>
    </div>
  </div>
</#macro>

<#--
	Construct a Installation record.
	WARNING! if showPublisher is true an action method action.getOrganization(UUID) must exist to return the matching org
-->
<#macro installation installation maxDescriptionLength=500 showPublisher=false>
<div class="result">
    <h3><@s.text name="enum.installationtype.${installation.type!}"/></h3>
    <h2>
        <strong>

        <#-- installation name and hyperlinked to its corresponding page -->
          <#if installation.title?has_content>
              <a href="<@s.url value='/installation/${installation.key}'/>">${installation.title}</a>
          </#if>

        </strong>
    </h2>

  <#if showPublisher && installation.organizationKey??>
      <p>
        <#assign publisher=action.getOrganization(installation.organizationKey) />
          Hosted by <a href="<@s.url value='/publisher/${publisher.key}'/>" title="${publisher.title}">${publisher.title}</a>.
      </p>
  </#if>

    <div class="footer">
      <#if installation.description?has_content>
          <p class="note semi_bottom">${common.limit(installation.description, maxDescriptionLength)}</p>
      </#if>
    </div>
</div>
</#macro>


<#--
	Construct a large data publisher record with a description.
-->
<#macro publisherWithDescription publisher>
  <div class="result">
    <h2>
      <strong>

      <#-- name and hyperlinked to its corresponding page -->
      <#if publisher.title?has_content>
        <a href="<@s.url value='/publisher/${publisher.key}'/>">${publisher.title}</a>
      </#if>

      </strong>
      <#-- If anything needs to be placed next to the title, put it here -->
      <#if publisher.numPublishedDatasets gt 0>
        <span class="note">${publisher.numPublishedDatasets} published datasets.</span>
      </#if>
    </h2>

    <div class="footer">
      <#if publisher.description?has_content>
        <p class="note semi_bottom">${publisher.description}</p>
      </#if>
    </div>
  </div>
</#macro>

<#--
	Construct a simple data publisher record useful for article blocks.
-->
<#macro publisher publisher>
<li>
  <a href="<@s.url value='/publisher/${publisher.key}'/>">${publisher.title!"???"}</a>
  <span class="note">A data publisher
    <#if publisher.city?? || publisher.country??>from <@common.cityAndCountry publisher/></#if>
    <#if (publisher.numPublishedDatasets > 0)>with ${publisher.numPublishedDatasets} published datasets</#if>
   </span>
</li>
</#macro>


<#macro dLink download>
<a href='/occurrence/search?${action.getQueryParams(download.request.predicate)!""}'>query</a> latest data
</#macro>

<#--
  requires a few action methods to exist !!!:

 - action.getHumanFilter()
 - action.getQueryParams()
-->
<#macro dFilter download>
  <#assign filterMap=action.getHumanFilter(download.request.predicate)!""/>
  <#assign queryParams=action.getQueryParams(download.request.predicate)!""/>
  <table class="download-filter">
    <#if !download.request.predicate?has_content>
        <tr>
            <th>All data</th>
            <td></td>
        </tr>
    <#elseif filterMap?has_content>
      <#list filterMap?keys as param>
          <tr>
              <th><@s.text name="search.facet.${param}" /></th>
              <td><#list filterMap.get(param) as val><span>${val}</span><#if val_has_next>,</#if></#list></td>
          </tr>
      </#list>
    <#else>
        <tr>
            <th>Raw query</th>
            <td>${download.request.predicate!"All data"}</td>
        </tr>
    </#if>
  </table>
</#macro>

<#--
  requires a few action methods to exist !!!:

 - action.getHumanFilter()
 - action.getQueryParams()
 - action.isDownloadRunning()
-->
<#macro downloadFilter download showCancel=false showStatus=true showResultDivider=true>
  <#if showResultDivider>
    <div class="result">
      <div class="footer">
  </#if>
  <#if download.doi??>
  <div class="label"><@common.doi download.doi /></div>
  </#if>
  <dl>
      <dt>Filter</dt>
      <dd>
          <#assign filterMap=action.getHumanFilter(download.request.predicate)!""/>
          <#assign queryParams=action.getQueryParams(download.request.predicate)!""/>
          <#assign searchLink='/occurrence/search'/>
          <#if queryParams?has_content>
            <#assign searchLink='/occurrence/search?'+ queryParams!""/>
          </#if>
          <table class="table">
          <#if !download.request.predicate?has_content>
            <tr data-target="${searchLink}" class="rowlink">
              <th>None</th>
              <td></td>
            </tr>
          <#elseif filterMap?has_content>
            <#list filterMap?keys as param>
              <tr data-target="${searchLink}" class="rowlink">
                <th><@s.text name="search.facet.${param}" /></th>
                <td><#list filterMap.get(param) as val><span>${val}</span><#if val_has_next>,</#if></#list></td>
              </tr>
            </#list>
          <#else>
              <tr data-target="${searchLink}" class="rowlink">
                <th>Raw Filter</th>
                <td>${download.request.predicate!"None"}</td>
              </tr>
          </#if>
          </table>
      </dd>

      <#if showStatus>
      <dt>Status</dt>
      <dd>
        <#if download.available>
          <!-- cfg.wsOcc is not public, but needed for authentication. Therefore wsOccPublic was created which is public -->
          Ready for <a href="${cfg.wsOccPublic}occurrence/download/request/${download.key}.zip">download</a>
          <#if download.size?has_content>(${action.getHumanRedeableBytesSize(download.getSize())} </#if>
          <#if download.totalRecords?has_content>${download.totalRecords} records - </#if>
          <#if download.numberDatasets?has_content>${download.numberDatasets} datasets)</#if>
        <#elseif showCancel && action.isDownloadRunning(download.status)>
          Still running. Do you want to <a href="<@s.url value='/user/download/cancel?key=${download.key}'/>">cancel</a> the query?
        <#else>
          <@s.text name="enum.downloadstatus.${download.status}" />
        </#if>
      </dd>
      </#if>
      <dt>Created</dt>
      <dd>${download.created?date?string.medium}</dd>

      <#nested />
  </dl>
  <#if showResultDivider>
      </div>
    </div>
  </#if>
</#macro>

<#macro downloadUsage du queryParams>
<@result>
<dl>
    <dt>Dataset</dt>
    <dd><a href="<@s.url value='/dataset/${du.datasetKey}'/>"><#if du.datasetTitle??>${du.datasetTitle}<#else>${du.datasetKey}</#if></a><#if du.datasetDOI??><br> <a class="doi" href="${du.datasetDOI.url}">${du.datasetDOI}</a></#if></dd>

    <dt>Records</dt>
    <dd><a href="<@s.url value='/occurrence/search?${queryParams}'/>">${du.numberRecords} records</a> from this dataset included at time of download</dd>

  <#if du.datasetDOI??>
    <dt>Identifier</dt>
    <dd><@common.doilink doi=du.datasetDOI /></dd>
  </#if>

  <#if du.datasetCitation??>
      <dt>Citation</dt>
      <dd>${du.datasetCitation}</dd>
  </#if>
</dl>
</@result>
</#macro>

<#macro result>
<div class="result">
  <div class="footer">
  <#nested />
  </div>
</div>
</#macro>
