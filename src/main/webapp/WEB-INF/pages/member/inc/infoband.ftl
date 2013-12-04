<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR A MEMBER PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 <#assign tab="info"/>
-->
<content tag="infoband">

  <h1 class="fullwidth">${common.limit(member.title, 70)}</h1>

  <h3>
    <@s.text name="enum.membertype.${type}"/><#if member.homepage?has_content>.
      More info at: <a href="${member.homepage}" target="_blank" title="Homepage">${member.homepage}</a>
    </#if>
  </h3>

  <#if keywords?has_content>
    <ul class="tags">
      <#list keywords as k>
          <li>
              <a href="<#if type=='PUBLISHER'><@s.url value='/publisher/search?search=${k}'/><#else>#</#if>" title="${k}">${k}</a>
          </li>
      </#list>
    </ul>
  </#if>
</content>

<content tag="tabs">
  <#if tabhl!false>
    <#assign hl="highlighted" />
  </#if>
  <ul class="${hl!}">
    <li<#if (tab!"")=="info"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/${type.name()?lower_case}/${id}'/>" title="Information"><span>Information</span></a>
    </li>
  </ul>
</content>
