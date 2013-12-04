<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/typespecimen.ftl" as types>
<html>
<head>
  <title>${usage.scientificName} - Checklist View</title>
  <content tag="extra_scripts">
      <#-- 
        Set up the map if only we will use it.  
        Maps are embedded as iframes, but we register event listeners to link through to the occurrence
        search based on the state of the widget.
      -->
      <#if nub && numOccurrences gt 0>
         <script type="text/javascript" src="${cfg.tileServerBaseUrl!}/map-events.js"></script>
         <script type="text/javascript">
             new GBIFMapListener().subscribe(function(id, searchUrl) {
               $("#geoOccurrenceSearch").attr("href", "<@s.url value='/occurrence/search'/>?" +  searchUrl);
             });
         </script>
      </#if>
      
      <#-- shadowbox to view large images -->
      <link rel="stylesheet" type="text/css" href="<@s.url value='/js/vendor/fancybox/jquery.fancybox.css?v=2.1.4'/>">
      <script type="text/javascript" src="<@s.url value='/js/vendor/fancybox/jquery.fancybox.js?v=2.1.4'/>"></script>
      <link rel="stylesheet" type="text/css" href="<@s.url value='/js/vendor/fancybox/helpers/jquery.fancybox-buttons.css?v=1.0.5'/>">
      <script type="text/javascript" src="<@s.url value='/js/vendor/fancybox/helpers/jquery.fancybox-buttons.js?v=1.0.5'/>"></script>

      <script type="text/javascript">
      // taxonomic tree state
      var $taxoffset= 0, loadedAllChildren=false;

      function renderUsages($ps, data){
        // hide loading wheel
        $ps.find(".loadingTaxa").fadeOut("slow");
        $(data.results).each(function() {
          var speciesLink = "<@s.url value='/species/'/>" + this.key;
          $htmlContent = '<li spid="' + this.key + '">';
          $htmlContent += '<span class="sciname"><a href="'+speciesLink+'">' + canonicalOrScientificName(this) + "</a></span>";
          $htmlContent += '<span class="rank">' + $i18nresources.getString("enum.rank." + (this.rank || "unknown")) + "</span>";
          if (this.numDescendants>0) {
            $htmlContent += '<span class="count">' + addCommas(this.numDescendants) + " descendants</span>";
          }
          $htmlContent += '</span></li>';
          $ps.find(".sp ul").append($htmlContent);
        })
      };

      // Function for loading and rendering children
      function loadChildren() {
        $ps=$("#taxonomicChildren");
        var $wsUrl = cfg.wsClb + "species/${id?c}/children?offset=" + $taxoffset + "&limit=25";
        // show loading wheel
        $ps.find(".loadingTaxa").show();
        //get the new list of children
        $.getJSON($wsUrl + '&callback=?', function(data) {
          renderUsages($ps, data);
          loadedAllChildren=data.endOfRecords;
        });
        $taxoffset += 25;
      }

      function loadDescription($descriptionKeys){
        var keys = $descriptionKeys.split(' ');
        // remove current description
        $("#description div.inner").empty();
        $.each(keys, function(index, k) {
          var key = $.trim(k);
          if (key) {
            var $wsUrl = cfg.wsClb + "description/" + key;
            $.getJSON($wsUrl + '?callback=?', function(data) {
              $htmlContent = "<h3>"+(data.type || "Description") +"</h3>";
              $htmlContent += "<p>"+data.description+"</p>";
              $htmlContent += '<p id="descriptionSrc'+index+'" class="note"><strong>Source</strong>: </p>';
              if (data.license) {
                  $htmlContent += '<p class="note"><strong>License</strong>: '+data.license+'</p>';
              }
              $("#description div.inner").append($htmlContent);
              $("#description div.inner").append("<br/><br/>");
              if (data.source) {
                $("#descriptionSrc"+index).append(data.source);
              } else {
                <#if nub>
                  $.getJSON(cfg.wsReg + "dataset/" + data.datasetKey + "?callback=?", function(dataset) {
                    $("#descriptionSrc"+index).append(dataset.title);
                  });
                <#else>
                  $("#descriptionSrc"+index).hide();
                </#if>
              }
            });
          }
        })
      }

      // show topics for a language
      function showLanguageTopics(lang){
          $("#description .topics").hide();
          $("#topics"+lang).show();
          $topicLi = $("#topics"+lang + " .topic:first");
          if ($topicLi.length > 0) {
            loadDescription($topicLi.attr("data-descriptionKeys"));
          };
          // adjust description height to ToC
          var tocHeight = $("#description div.right").height() - 5;
          if (tocHeight > 350) {
            $("#description div.inner").height(tocHeight);
          }
      }

      function initDescriptions(){
        <#if !descriptionToc.listLanguages().isEmpty()>
            $("#description .topic").click(function(event) {
              event.preventDefault();
              loadDescription( $(this).attr("data-descriptionKeys") );
            });
            $("#description .toclang").click(function(event) {
              event.preventDefault();
              showLanguageTopics($(this).attr("data-lang"));
            });
            // show first language ToC,
            // TODO: try to use in this order: user locale, english, first lang
            $showLang = "${descriptionToc.listLanguages()[0]}";
            showLanguageTopics($showLang);
        </#if>
      }

      $(function() {
        // taxonomic tree
        loadChildren();
        $("#taxonomicChildren .inner").scroll(function(){
          var triggerHeight = $("#taxonomicChildren .sp").height() - $(this).height() - 100;
          if (!loadedAllChildren && $("#taxonomicChildren .inner").scrollTop() > triggerHeight){
            loadChildren();
          }
        });

        // description TOC
        initDescriptions();

        // image slideshow
        $("#images").speciesSlideshow(${id?c});
      });
    </script>
    <style type="text/css">
        #images .title {
          overflow: hidden;
          max-height: 85px;
        }
        #content #images .scrollable {
          height: 350px;
        }
    </style>
  </content>
<#-- RDFa -->
  <meta property="dwc:scientificName" content="${usage.scientificName!}"/>
  <meta property="dwc:kingdom" content="${usage.kingdom!}"/>
  <meta property="dwc:datasetID" content="${usage.datasetKey}"/>
  <meta property="dwc:datasetName" content="${(dataset.title)!"???"}"/>
  <meta rel="dc:isPartOf" href="<@s.url value='/dataset/${usage.datasetKey}'/>"/>
</head>
<body class="species">

<#assign tab="info"/>
<#include "/WEB-INF/pages/species/inc/infoband.ftl">
<#if !nub>
<#-- Warn that this is not a nub page -->
<@common.notice title="This is a particular view of ${usage.canonicalOrScientificName!}">
  <p>This is the <em>${usage.scientificName}</em> view,
    as seen by
      <#if constituent??><a href="<@s.url value='/dataset/${constituent.key}'/>">${constituent.title}</a>, a constituent of the </#if>
      <a href="<@s.url value='/dataset/${usage.datasetKey}'/>">${(dataset.title)!"???"}</a> checklist.
  </p>

  <p>
    <#if usage.nubKey?exists>
      Remember that you can also check the
      <a href="<@s.url value='/species/${usage.nubKey?c}'/>">GBIF view on ${usage.canonicalOrScientificName!}</a><#if usage.origin! != "SOURCE" || !verbatimExists>.</#if>
    </#if>
    <#if usage.origin! == "SOURCE">
      <#-- only show the link to a verbatim page if it indeed exists. Some old checklists need to be reindexed to have verbatim data stored -->
      <#if verbatimExists>
        <#if usage.nubKey?exists> or <#else> You can also see </#if>
        the <a href="<@s.url value='/species/${id?c}/verbatim'/>">verbatim version</a>
        submitted by the data publisher.
      </#if>
    <#else>
      </p>

      <p>
      This record has been created during indexing and did not explicitly exist in the source data as such.
      It was created as <@s.text name="enum.origin.${usage.origin}"/>.
    </#if>
  </p>
</@common.notice>
</#if>


<@common.article id="overview" title="Overview">
<div class="left">

  <div class="col">
    <h3>Full Name</h3>
    <p><#if usage.isExtinct()!false>† </#if>${usage.scientificName}</p>
    <#if vernacularNames?has_content>
      <h3>Common names</h3>
      <ul>
        <#list vernacularNames?keys as vk>
          <#assign names=vernacularNames.get(vk)/>
          <#assign v=names[0]/>
          <li>${v.vernacularName}<#if v.language??> <span class="small">${v.language.getIso3LetterCode()}</span></#if>
            <@common.usageSources components=names showSource=!usage.isNub() showChecklistSource=usage.isNub() />
          </li>
          <#if vk_has_next && vk_index==2>
            <li class="more"><a href="<@s.url value='/species/${id?c}/vernaculars'/>">more</a></li>
            <#break />
          </#if>
        </#list>
      </ul>
    </#if>

    <#if (usage.synonyms?size>0)>
      <h3>Synonyms</h3>
      <ul class="no_bottom">
        <#list usage.synonyms as syn>
          <li><a href="<@s.url value='/species/${syn.key?c}'/>">${syn.scientificName}</a></li>
          <#-- only show 5 synonyms at max -->
          <#if syn_has_next && syn_index==4>
            <li class="more"><a href="<@s.url value='/species/${id?c}/synonyms'/>">more</a></li>
            <#break />
          </#if>
        </#list>
      </ul>
    </#if>

  </div>

  <div class="col">
    <h3>Taxonomic status</h3>
    <p>
      <@s.text name="enum.taxstatus.${usage.taxonomicStatus!'UNKNOWN'}"/>

      <#if usage.synonym>
        of <a href="<@s.url value='/species/${usage.acceptedKey?c}'/>">${usage.accepted!"???"}</a>
      <#elseif usage.rank??>
        <@s.text name="enum.rank.${usage.rank}"/>
      </#if>
    </p>

    <#if usage.accordingTo?has_content>
      <h3>According to</h3>
      <p>${usage.accordingTo}</p>
    </#if>

    <#if usage.publishedIn?has_content>
      <h3>Published in</h3>
      <p>${usage.publishedIn}</p>
    </#if>

    <#if basionym?has_content>
      <h3>Original name</h3>
      <p><a href="<@s.url value='/species/${basionym.key?c}'/>">${basionym.scientificName}</a></p>
    </#if>

    <#if usage.nomenclaturalStatus?has_content>
      <h3>Nomenclatural status</h3>
      <p><@common.renderNomStatusList usage.nomenclaturalStatus /></p>
    </#if>

    <#if (usage.livingPeriods?size>0)>
      <h3>Living period</h3>
      <p><#list usage.livingPeriods as p>${p?cap_first}<#if p_has_next>; </#if></#list></p>
    </#if>

    <#if habitats?has_content>
      <h3>Habitat</h3>
      <p>
        <#list habitats as h>${h?cap_first}<#if h_has_next>, </#if></#list>
      </p>
    </#if>

    <#if (usage.threatStatus?size>0)>
      <h3>Threat status</h3>
      <p><#list usage.threatStatus as t><#if t?has_content><@s.text name="enum.threatstatus.${t}"/><#if t_has_next>; </#if></#if></#list></p>
    </#if>

  </div>

  <#if usage.remarks?has_content>
    <div>
      <h3>Remarks</h3>
      <p>${usage.remarks}</p>
    </div>
  </#if>
</div>

<#-- Keep first image with url -->
<#list usage.images as img>
  <#if img.image??>
    <#if !primeImage?exists><#assign primeImage=img/></#if>
  </#if>
</#list>

<div class="right">
  <#if primeImage?exists>
    <div class="species_image">
      <a href="#images" class="images"><span><img src="../img/placeholder.png" data-load="${action.getImageCache(primeImage.image,'s')}" /></span></a>
    </div>
  </#if>

  <h3>External links</h3>
  <ul>
  <#list usage.externalLinks as i>
    <#if i.title?has_content || (i.datasetKey?has_content && datasets.get(i.datasetKey)??)>
    <li>
      <#if i.identifierLink?has_content>
        <a href="${i.identifierLink}" title="${i.title!i.type!}">
      </#if>
      <#if i.title?has_content>
        ${i.title}
      <#else>
        ${common.limit( datasets.get(i.datasetKey).title ,28)}
      </#if>
      <#if i.identifierLink?has_content>
        </a>
      </#if>
    </li>
    </#if>
  </#list>
  <#if usage.nubKey??>
    <li><a target="_blank" href="http://eol.org/search/?q=${usage.canonicalOrScientificName}" title="Encyclopedia of Life">Encyclopedia of Life</a></li>
  </#if>
  <#if usage.canonicalName??>
    <li><a target="_blank" href="http://www.biodiversitylibrary.org/name/${usage.canonicalName?replace(' ','_')}">Biodiversity Heritage Library</a></li>
  </#if>
  </ul>

    <dl class="identifier">
      <dt>GBIF ID</dt>
      <dd><a href="#" title="GBIF ID ${id?c}">${id?c}</a></dd>
      <#if !nub && usage.sourceId??>
        <dt>Source ID</dt>
        <dd><a href="#" title="${usage.sourceId}">${usage.sourceId}</a></dd>
      </#if>
      <#list usage.identifiers as i>
      <#if i.type != 'URL' && i.type!='SOURCE_ID'>
        <dt>${i.type}</dt>
        <dd><a href="${i.identifierLink!'#'}" title="${i.identifier}">${common.limit(i.identifier ,22)}</a></dd>
      </#if>
      </#list>
    </dl>
</div>
</@common.article>

<#-- Taxon maps are only calculated for the nub taxonomy -->

<#if nub && numOccurrences gt 0>
<a name="map"></a>
<article class="map">
  <header></header>


  <div class="content">
    <div class="map">
      <iframe id="map" name="map" src="${cfg.tileServerBaseUrl!}/index.html?type=TAXON&key=${usage.key?c}&resolution=${action.getMapResolution(numGeoreferencedOccurrences)}" allowfullscreen height="100%" width="100%" frameborder="0"/></iframe>
    </div>
    <div class="header">
      <div class="right"><h2>Georeferenced data</h2></div>
    </div>
	<div class="right">
      <div class="inner">
        <#if numGeoreferencedOccurrences gt 0>
          <h3>View records</h3>
          <p>
            <a href="<@s.url value='/occurrence/search?taxon_key=${usage.key?c}&GEOREFERENCED=true&SPATIAL_ISSUES=false'/>">All ${numGeoreferencedOccurrences} </a>
            |
            <a href="<@s.url value='/occurrence/search?taxon_key=${usage.key?c}&BOUNDING_BOX=90,-180,-90,180&SPATIAL_ISSUES=false'/>" id='geoOccurrenceSearch'>In viewable area</a>
          </p>
        </#if>

        <#if usage.distributions?has_content>
          <h3>Distributions</h3>
          <p>
             Text based <a href="<@s.url value='/species/${id?c}/distributions'/>">distributions</a> present in some sources.
          </p>
        </#if>
      </div>
    </div>
  </div>
  <footer></footer>
</article>
<#else>
  <#if usage.distributions?has_content>
  <@common.article id="distribution" title="Distribution range">
    <div class="fullwidth">
      <ul class="notes">
        <#assign skipped=0/>
        <#list usage.distributions as d>
          <#if d.locationId?? || d.country?? || d.locality?? >
            <li>
              <#if d.country??>${d.country.title}</#if>
              ${d.locationId!} ${d.locality!}
              <span class="note">
                ${d.lifeStage!} ${d.temporal!} <@s.text name='enum.occurrencestatus.${d.status!"PRESENT"}'/>
                <#if d.threatStatus??><@s.text name="enum.threatstatus.${d.threatStatus}"/></#if>
                <#if d.establishmentMeans??><@s.text name='enum.establishmentmeans.${d.establishmentMeans}'/></#if>
                <#if d.appendixCites??>Cites ${d.appendixCites}</#if>
              </span>
            </li>
          <#else>
            <#assign skipped=skipped+1/>
          </#if>
          <#-- only show 8 distributions at max -->
          <#if d_has_next && d_index==7+skipped>
           <li class="more"><a href="<@s.url value='/species/${id?c}/distributions'/>">more</a></li>
            <#break />
          </#if>
        </#list>
      </ul>
    </div>
  </@common.article>
  </#if>
</#if>


<@common.article id="taxonomy" title="Subordinate taxa" titleRight="Classification" class="taxonomies">
    <div class="left">
      <#if usage.numDescendants gt 0>
        <div id="taxonomicChildren">
          <div class="loadingTaxa"><img src="../img/taxbrowser-loader.gif" alt=""></div>
          <div class="inner">
            <div class="sp">
              <ul>
              </ul>
            </div>
          </div>
        </div>
      <#else>
        <p>
           There are no subordinate taxa<#if usage.rank??> for this <@s.text name="enum.rank.${usage.rank}"/></#if>.<br/>
           You can explore the higher classification on the right.
        </p>
      </#if>
    </div>

    <div class="right">
      <dl>
      <#list rankEnum as r>
        <dt><@s.text name="enum.rank.${r}"/></dt>
        <dd>
          <#if usage.getHigherRankKey(r)??>
            <#if usage.getHigherRankKey(r) == usage.key>
              ${usage.canonicalOrScientificName}
            <#else>
              <a href="<@s.url value='/species/${usage.getHigherRankKey(r)?c}'/>">${usage.getHigherRank(r)}</a>
            </#if>
          <#elseif (usageMetrics.getNumByRank(r)!0) gt 0>
            <#-- TODO: check how to search for accepted only, removed status=ACCEPTED cause its too strict -->
            <a href="<@s.url value='/species/search?dataset_key=${usage.datasetKey}&rank=${r}&highertaxon_key=${usage.key?c}'/>">${usageMetrics.getNumByRank(r)}</a>
          <#else>
            ---
          </#if>
        </dd>
      </#list>
        <dt>&nbsp;</dt>
        <dd><a href="<@s.url value='/species/${id?c}/classification'/>">complete classification</a></dd>
      </dl>
    </div>
</@common.article>


<#if !descriptionToc.isEmpty()>
  <@common.article id="description" title='Description' class="">
    <div class="left">
      <div class="inner">
        <h3>Description</h3>
        <p></p>
      </div>
    </div>

    <div class="right">
      <h3>Table of Contents</h3>
      <#if descriptionToc.listLanguages().size() gt 1>
        <#list descriptionToc.listLanguages() as lang>
          <a class="toclang" href="#" data-lang="${lang}"><#if lang.getIso3LetterCode()?has_content>${lang.getIso3LetterCode()?upper_case}<#else>${lang.name()}</#if></a><#if lang_has_next>, </#if>
        </#list>
        <br/><br/>
      </#if>

      <#list descriptionToc.listLanguages() as lang>
        <ul id="topics${lang}" class="topics" class="no_bottom">
          <#assign topicMap = descriptionToc.listTopicEntries(lang)>
          <#list topicMap?keys as topic>
            <li><a class="topic" data-descriptionKeys="<#list topicMap.get(topic) as did>${did?c} </#list>">${topic?capitalize}</a></li>
          </#list>
        </ul>
      </#list>
    </div>
  </@common.article>
</#if>

<#if primeImage?exists>
  <@common.article id="images">
    <div class="species_images">
      <a class="controller previous" href="#" title="Previous image"></a>
      <a class="controller next" href="#" title="Next image"></a>
      <div class="scroller">
        <div class="photos"></div>
      </div>
    </div>

    <div class="right">
      <h2 class="title">...</h2>
      <div class="scrollable">

      </div>
    </div>
    <div class="counter">1 / 1</div>
  </@common.article>
</#if>

<#if usage.nubKey??>
  <@common.article id="appearsin" title="Appears in">
    <div class="fullwidth">
      <div class="col">
        <h3>Occurrence datasets</h3>
        <ul class="notes">
          <#assign counter=0 />
          <#list occurrenceDatasetCounts?keys as uuid>
            <#if datasets.get(uuid)??>
              <#assign counter=counter+1 />
              <#assign title=datasets.get(uuid).title! />
              <li>
                <a title="${title}" href="<@s.url value='/occurrence/search?taxon_key=${usage.nubKey?c}&dataset_key=${uuid}'/>">${common.limit(title, 55)}</a>
                <span class="note"> in ${occurrenceDatasetCounts.get(uuid)!0} occurrences</span>
              </li>
            </#if>
            <#if uuid_has_next && counter==6>
              <li class="more"><a href="<@s.url value='/species/${usage.nubKey?c}/datasets?type=OCCURRENCE'/>">${occurrenceDatasetCounts?size} more</a></li>
              <#break />
            </#if>
          </#list>
          <#if !occurrenceDatasetCounts?has_content>
              <li>None</li>
          </#if>
        </ul>
      </div>

      <div class="col">
        <h3>Checklists</h3>
        <ul class="notes">
          <#list related as rel>
            <#if datasets.get(rel.datasetKey)??>
              <#assign title=datasets.get(rel.datasetKey).title! />
              <li><a title="${title}" href="<@s.url value='/species/${rel.key?c}'/>">${common.limit(title, 55)}</a>
                <span class="note">as ${rel.scientificName}</span>
              </li>
            </#if>
            <#if rel_has_next && rel_index==5>
              <li class="more"><a href="<@s.url value='/species/${usage.nubKey?c}/datasets?type=CHECKLIST'/>">${related?size} more</a></li>
              <#break />
            </#if>
          </#list>
          <#if !related?has_content>
              <li>None</li>
          </#if>
        </ul>
      </div>
    </div>
  </@common.article>
</#if>

<#if (usage.typeSpecimens?size>0)>
  <@common.article id="types" title="Types">
    <div class="fullwidth">
      <#list usage.typeSpecimens as ts>
        <ul>
          <li>
          <#-- require a type status or assume its type species/genus for higher ranks in case its null and we got a sciname -->
            <#assign isNameType = (usage.rank?? && !usage.rank.isSpeciesOrBelow() && ts.scientificName?has_content) />
            <#if ts.typeStatus?has_content || isNameType>
              <strong>${(ts.typeStatus!"TYPE")?capitalize}</strong>
              <#if ts.scientificName?has_content> -
                <#if isNameType || ts.typeStatus=='TYPE_GENUS' || ts.typeStatus=='TYPE_SPECIES'>
                    <a href="<@s.url value='/species/search?q=${ts.scientificName}'/>">${ts.scientificName}</a>
                <#else>
                    <a href="<@s.url value='/occurrence/search?TAXON_KEY=${ts.scientificName}'/>">${ts.scientificName}</a>
                </#if>
                <@common.usageSource component=ts showChecklistSource=nub />
              </#if>
              <@types.details ts />
            </#if>
          </li>
        </ul>

        <#-- only show 4 type specimens at max -->
        <#if ts_has_next && ts_index==3>
          <p class="more">
            <a href="<@s.url value='/species/${id?c}/types'/>">more</a>
          </p>
          <#break>
        </#if>
      </#list>
    </div>
  </@common.article>
</#if>

<#if (usage.references?size>0)>
  <@common.article id="references" title="Bibliography">
    <div class="fullwidth">
      <#if usage.references?has_content>
        <#list usage.references as ref>
          <p>
            <#if ref.link?has_content><a href="${ref.link}">${ref.citation}</a><#else>${ref.citation}</#if>
            <#if ref.doi?has_content><br/>DOI:<a href="http://dx.doi.org/${ref.doi}">${ref.doi}</a></#if>
          </p>
          <#-- only show 8 references at max. If we have 8 (index=7) we know there are more to show -->
          <#if ref_has_next && ref_index==7>
            <p class="more"><a href="<@s.url value='/species/${id?c}/references'/>">more</a></p>
            <#break />
          </#if>
        </#list>
      </#if>
    </div>
  </@common.article>
</#if>

<#-- LEGAL -->
<#if constituent??>
  <#assign prefix>${usage.scientificName}<#if usage.accordingTo?has_content> recognized by ${usage.accordingTo}</#if>, ${constituent.title} in </#assign>
</#if>
<@common.citationArticle rights=usage.rights!dataset.rights! dataset=dataset publisher=publisher prefix=prefix />


<#if !usage.isNub()>
  <@common.notice title="Further information">
  <p>There may be more details available about this name usage in the
    <a href="<@s.url value='/species/${id?c}/verbatim'/>">verbatim version</a> of the record
  </p>
  </@common.notice>
<#elseif usage.origin??>
  <@common.notice title="Source information">
  <p>This backbone name usage exists because
    <#if usage.origin == "SOURCE">
      it was found in another checklist at the time the backbone was built.
      <#if nubSourceExists>
        <br/>View the <a class="source" data-baseurl="<@s.url value='/species/'/>" href="<@s.url value='/species/${usage.sourceId}'/>">primary source name usage</a>.
      <#else>
        The primary source name usage <#if usage.sourceId?has_content>(${usage.sourceId})</#if> has since been removed from the portal.
      </#if>
    <#else>
      <@s.text name="enum.origin.${usage.origin}"/>.
    </#if>
  </p>
  </@common.notice>
</#if>

</body>
</html>
