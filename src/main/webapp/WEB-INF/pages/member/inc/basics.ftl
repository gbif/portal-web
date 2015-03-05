<#-- @ftlvariable name="" type="org.gbif.portal.action.member.MemberBaseAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>

<div class="left">
    <h3>Full title</h3>
    <p>${member.title}</p>

  <#if member.description?has_content>
    <h3>Description</h3>
    <p>${action.linkText(member.description)}</p>
  </#if>

  <#if member.metadataLanguage?has_content>
  <h3>Language of metadata</h3>
  <p>${member.metadataLanguage}</p>
  </#if>

  <#if primaryContacts?has_content>
    <@common.contactList contacts=primaryContacts columns=3 showAllButton=false />
  </#if>
</div>


<div class="right">
  <#if member.logoUrl?has_content>
    <div class="logo_holder">
      <img src="<@s.url value='${member.logoUrl}'/>"/>
    </div>
  </#if>

  <#-- No address shown for members of type installation -->
  <#if type != "INSTALLATION">
    <h3>Address</h3>
    <@common.address adr=member />
  </#if>

  <#if member.homepage?has_content>
    <h3>Website</h3>
    <#list member.homepage as home>
     <#if home?has_content>
      <p><a href="${home}" target="_blank">${home}</a></p>
     </#if>
    </#list>
  </#if>

  ${extraRight!}

</div>
