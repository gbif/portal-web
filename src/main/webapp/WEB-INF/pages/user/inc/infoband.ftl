<#import "/WEB-INF/macros/common.ftl" as common>
<#--
 THIS INCLUDE GENERATES THE INFOBAND AND TABS FOR A USER PAGE
 to select a tab to be highlighted please assign on of the following to the freemarker variable "tab":

 <#assign tab="account"/>
 <#assign tab="download"/>
 <#assign tab="lists"/>

 To show yellow tabs instead of default grey ones please assign:
  <#assign tabhl=true />
-->

<content tag="infoband">
  <h1><#if currentUser.firstName?has_content>${currentUser.firstName} ${currentUser.lastName!}<#else>${currentUser.userName}</#if></h1>
  <h3>User account and personal settings</h3>
</content>

<content tag="tabs">
  <#if tabhl!false>
    <#assign hl="highlighted" />
  </#if>
  <ul class="${hl!}">
    <li<#if (tab!"")=="account"> class='selected ${hl!}'</#if>>
      <a href="${cfg.drupal}/user/${currentUser.key?c}/edit" title="Account"><span>Account</span></a>
    </li>
    <li<#if (tab!"")=="download"> class='selected ${hl!}'</#if>>
      <a href="<@s.url value='/user/download'/>" title="Downloads"><span>Downloads</span></a>
    </li>
  </ul>
</content>
