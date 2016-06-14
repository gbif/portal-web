## GBIF-Portal

Java Web Application to exposes the functionality that mostly is produced consuming the GBIF REST services, such
functionality includes:
  * Dataset: faceted search and detail dataset view.
  * Species: faceted search and detail view.
  * Occurrence: filtered search and detail view.
  * Publisher: search and detail view.
  * Network/Node: simple search and detail view.
  * Netwoork: detail view.
  * IPT: display information about releases and statistics.
  * Developer: documentation about the REST API services.
  * Infrastructure: documentation about the occurrence data indexing, processing and tools.
  
This portal was developed using the following technologies: [Strust2](http://struts.apache.org/), [Freemarker](http://freemarker.org/), 
[Less](http://lesscss.org/), [Leaflet](http://leafletjs.com/) and  [JQuery](https://jquery.com/). 

## How to built the project
This project requires a Maven with the following settings defined in the properties section:

```
<profile>
  <id>gbif-portal</id>
  <properties>
        <cargo.context>portal</cargo.context>
        <devMode>false</devMode>
        <notDevMode>true</notDevMode>
        <baseurl>http://www.gbif-dev.org</baseurl>
        <api.baseurl>http://api.gbif-dev.org/v1</api.baseurl>
        <servername>http://www.gbif-dev.org</servername>
        <drupal.url>http://www.gbif-dev.org</drupal.url>
        <url.includeContext>false</url.includeContext>        
        <httpTimeout>60000</httpTimeout>
        <maxHttpConnections>100</maxHttpConnections>
        <maxHttpConnectionsPerRoute>100</maxHttpConnectionsPerRoute>
        <annosys.url>https://annosys.bgbm.fu-berlin.de/AnnoSysTest/</annosys.url> 
        <registry.ws.url>http://api.gbif-dev.org/v1/</registry.ws.url>
        <checklistbank.ws.url>http://api.gbif-dev.org/v1/</checklistbank.ws.url>
        <checklistbank.match.ws.url>http://api.gbif-dev.org/v1/species/match/</checklistbank.match.ws.url>
        <occurrence.ws.url>http://api.gbif-dev.org/v1/</occurrence.ws.url>
        <occurrence.ws.url.public>http://api.gbif-dev.org/v1/</occurrence.ws.url.public>
        <tile-server.url>http://api.gbif-dev.org/v1/map</tile-server.url>
        <image-cache.url>http://api.gbif-dev.org/v1/image</image-cache.url>
        <metrics.ws.url>http://api.gbif-dev.org/v1/</metrics.ws.url>   
        <drupal.cookiename>drupal_cookiename</drupal.cookiename>        
        <drupal.db.host>mysqlserver</drupal.db.host>
        <drupal.db.url>jdbc:mysql://mysqlserver:3306/drupal_db?useUnicode=true&amp;characterEncoding=UTF8&amp;characterSetResults=UTF8</drupal.db.url>
        <drupal.db.name>drupal_db_username</drupal.db.name>
        <drupal.db.username>drupal_db_password</drupal.db.username>
        <drupal.db.poolSize>8</drupal.db.poolSize>
        <drupal.db.connectionTimeout>2000</drupal.db.connectionTimeout>
        <portal.application.secret></portal.application.secret>
      </properties>
</profile>
```
Using the profile above, exceute the Maven command:

```
mvn clean jetty:run -Pgbif-portal
```

## Releasing the project
To release this project use the following Maven command:
```
mvn clean package verify -Pgbif-portal,release
```

## Project structure

The initial version of this project was created using this a base design that is documented [here](draftportal.md).

### Apache Struts2 usage

#### URL conventions
All the URLs are exposed following a restful pattern, pretty urls like the following.
The examples are mainly for datasets, but would be similar for species, occurrences, etc

/ (portal home)
/dataset (datasets home)
/dataset/search?q=puma (search datasets for the word puma)
/dataset/{UUID} (detail page for specific dataset)
/dataset/{UUID}/stats (stats page for specific dataset X)
/dataset/{UUID}/activity (activity page for specific dataset X)
/dataset/{UUID}/discussion (discussion page for specific dataset X)

#### Action mapping
we use wildcard mapping with the namedVariable pattern matcher for the default action mapper.
http://struts.apache.org/2.x/docs/wildcard-mappings.html

The conventions plugin (http://struts.apache.org/2.x/docs/convention-plugin.html) looked good, but failed to do the above urls with id params in the middle of the urls.
It also isnt as configurable as the explicit struts.xml definitions, for example to change http headers, content type, serving binary (eg image) streams, etc so it was finally not used.

#### Case sensitivity
URLs should be case insensitive. Struts, like servlets, seems case sensitive by default.
We need to see if we can change a setting or use a rewrite to lower case filter?

#### Internationalisation
We are going to stick to a single resource file. Markus's point of replacing the native struts2 text provider makes sense now.
not done yet as we expect major changes in the html still and its less work to replace the real strings once we reached a considerable stable state. Otherwise we also run into lots of orphaned entries. Use the struts tags for i18n, for example <@s.text name="menu.species"/>
Consider replacing the native struts2 text provider with a much simpler one we use in the IPT that increased page rendering with many getText lookups by more than 100% as the native one does an extensive resource bundle search across various classpaths and other places that we dont need if we stick to a single resource file.

##### Using i18n in JQuery
to make available the properties from Java's resource bundle to javascript, a jquery plugin is used: http://plugins.jquery.com/project/resourcebundle
To make any property available, this process should be followed:
1. On the Action responsible for passing the values to the ftl, create a getResourceBundleProperties() method that calls the superclass's method:  
  Example:
  ```
      MyAction extends BaseAction
         //this will return ALL properties
       public Map<String, String> getResourceBundleProperties() {
          return super.getResourceBundleProperties();
       }
         //this will return just properties starting with "rank."
       public Map<String, String> getResourceBundleProperties() {
          return super.getResourceBundleProperties("rank.");
       }
         //this will return just properties starting with "rank." and "species."
         //you can add as many prefixes as needed
       public Map<String, String> getResourceBundleProperties() {
           return super.getResourceBundleProperties("rank.", "species.");
       }
  ```
2.  To make use of the JQuery plugin, you just need to call it like:
    $i18nresources.getString("myi18nKey"); //where "myi18nKey" represents the key of a property loaded on step 1)
    from any javascript file.

Note on this: the plugin can't handle ResourceBundle parameters (${0}, etc)
If in the future we decide to change to another i18n jquery plugin, these things should be removed:
  * app.js:
      ```$i18nresources = $.getResourceBundle("resources");```
  * default.ftl: upper part of file
  ```
          <#-- Load bundle properties. The action class can filter out which properties
            to show according to their key's prefixes -->
          <#if resourceBundleProperties?has_content>
            <script id="resources" type="text/plain">
              <#list resourceBundleProperties?keys as property>
                ${property}=${resourceBundleProperties.get(property)}
              </#list>
            </script>
          </#if>
  ```
  * search for any reference to "$i18nresources" on the javascript files: these would need to change to the new plugin
  * ```BaseAction.java```:
    ```getResourceBundleProperties(String... prefix)``` method
  * any other Action class that implemented this method. (although, this method might be useful in other cases)


### Freemarker vs struts tags
Freemarker has support for iterating lists, displaying properties, including other templates, macro's, and so on. There is a small performance cost when using the struts tags instead of the Freemarker equivalent (eg. <s:property value="foo"/> should be replaced by ${foo}), so use as much of native freemarker as you can!

#### Freemarker Tips
Common pitfalls with freemarker are:

You need to handle null value explicitly. If nulls are encountered in places you render the variable, an exception will occurr. You need to explicitly tell freemarker what to do with nulls. The default operator (!) can be used or ?? to test for not null. To also test for empty string use ?has_content. Example ${dataset.title!"No title given"}

Freemarker renders non strings for humans by default based on the current locale. You can instruct freemarker to use different renderings. This is very important for numbers as parameters, as you will be surprised with commas otherwise. Render numbers for "computers" is done with ?c, e.g. ${u.taxonID?c}. Booleans also require special attention. To render simple true/false strings use ?string, e.g. ${u.isSynonym?string}, you can also specify the strings to be used.

BIG NOTE: if you have a freemarker error (exceptions) sitemesh will swallow it and you can't see it unless you remove sitemesh (sitemesh filter from struts).  Do we need Sitemesh
at all?  Markus thinks not, Tim thinks yes.

### Sitemesh
version3 is still in alpha and caused some NIO blocking with Jetty & Tomcat 7 and above in my tests.
The struts2 plugin for sitemesh also does not work with sitemesh3 and still waits to be rewritten.
We therefore still use the old 2.4.2 version with the 2 config files sitemesh.xml and decorators.xml

### Content fragments
as decorators cant access freemarker vars from the main page, we have to use custom sitemesh tags in the main page to pass content fragments to the decorators, for example to populate the green "infoband":

main page:
```
<content tag="infoband">
		<h2>Search datasets</h2>
		<form>
			<input type="text" name="search"/>
		</form>
</content>
```
inside the decorator these content tags can be reached via:
  ```${page.properties["page.infoband"]}```

#### Decorators
We use a single default.ftl decorator

Sitemesh exposes specific variables that contain content from the main page to be used in the decorators:
```
 <head><title> ==> ${title}
 <head> ==> ${head}
 <body> ==> ${body}
 <body class="xyz"> ==> ${page.properties["body.class"]!}
```
the default decorator is aware of the following content fragments and variables apart from the main ones above:
```
 meta.menu
 content tag="infoband"
 content tag="tabs"
```
#### Errors
If the underlying action results in an uncaught error, the sitemesh filter fails with a NPE and you cannot see the original struts stacktrace.
Only way I found to change that is disabling the SiteMeshFilter in the PortalListener and restart the server to try the same query again.

### Authentication/login
A RequireLoginInterceptor exists to protect actions or entire packages to only allow logged in users.
