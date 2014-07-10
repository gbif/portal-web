<#import "/WEB-INF/macros/common.ftl" as common>

<div class="left">
    <h3>Full title</h3>
    <p>${member.title}</p>

  <#if member.description?has_content>
    <h3>Description</h3>
    <p>${member.description}</p>
  </#if>

  <#if member.metadataLanguage?has_content>
  <h3>Language of metadata</h3>
  <p>${member.metadataLanguage}</p>
  </#if>

  <#if member.email?has_content>
  <h3>Email</h3>
   <#list member.email as email>
    <#if email?has_content>
      <p><a href="mailto:${email}">${email}</a></p>
    </#if>
   </#list>
  </#if>

  <#if member.phone?has_content>
  <h3>Phone</h3>
  <#list member.phone as phone>
    <#if phone?has_content>
      <p>${phone}</p>
    </#if>
  </#list>
  </#if>

  <#-- only publisher pages need to separate contacts into primary and other -->
  <#if primaryContacts?? && otherContacts??>
    <#if primaryContacts?has_content>
    <#-- show all link should get shown at bottom of other contacts, depending on whether there are other contacts -->
      <@common.contactList contacts=primaryContacts columns=3  showAllButton=(otherContacts?size == 0) title='Primary contacts'/>
    </#if>
    <#if otherContacts?has_content>
      <@common.contactList contacts=otherContacts columns=3 showAllButton=true title="Other contacts"/>
    </#if>
  <#elseif member.contacts?has_content>
      <@common.contactList contacts=member.contacts columns=3 showAllButton=true/>
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
