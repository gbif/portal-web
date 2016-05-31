<#-- @ftlvariable name="" type="org.gbif.portal.action.occurrence.SearchAction" -->
<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/macros/pagination.ftl" as macro>
<html>
  <head>
    <title>Occurrence Search Results</title>

    <content tag="extra_scripts">
      <script type="text/javascript" src="<@s.url value='/js/facets.js'/>"></script>
      <script type="text/javascript">
        //needed to avoid caching by Firefox's bfcache
        window.onunload = function(){ };
      </script>
    <link rel="stylesheet" href="<@s.url value='/js/vendor/datepicker/css/datepicker.css'/>"/>
    <link rel="stylesheet" href="<@s.url value='/js/vendor/tagit/jquery.tagit.css'/>"/>
    <link rel="stylesheet" href="<@s.url value='/js/vendor/tagit/tagit.ui-zendesk.css'/>"/>
    <#if !cfg.occurrenceFacetsEnabled>
      <link rel="stylesheet" href="<@s.url value='/css/occ_nofacets.css?v=3'/>"/>
    </#if>


<!--    <link rel="stylesheet" href="<@s.url value='/css/combobox.css?v=2'/>"/>    -->
    <script src='<@s.url value='/js/vendor/jquery.url.js'/>' type='text/javascript'></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-ui-1.8.17.min.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/portal_autocomplete.js'/>"></script>

    <!--Maps-->
    <link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.css'/>" />
    <link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/draw/leaflet.draw.css'/>" />
    <!--[if lte IE 8]><link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.ie.css'/>" /><![endif]-->
    <script type="text/javascript" src="<@s.url value='/js/vendor/leaflet/leaflet.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/leaflet/draw/leaflet.draw.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/occurrence_filters.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/datepicker/js/bootstrap-datepicker.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/inputmask/js/jquery.inputmask.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/inputmask/js/jquery.inputmask.date.extensions.js'/>"></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/tagit/tag-it.min.js'/>"></script>

    <script>
      var filtersFromRequest = new Object();
      var countryList = [<#list countries as country><#if country.official>{label:"${country.title}",iso2Lettercode:"${country.iso2LetterCode}"}<#if country_has_next>,</#if></#if></#list>];
      function addFilters(filtersFromRequest,filterKey,filterValue,filterLabel) {
        if(filterKey == 'HAS_GEOSPATIAL_ISSUE' || filterKey == 'HAS_COORDINATE'){
          filtersFromRequest[filterKey].push({ label: filterLabel, value:filterValue, key: null, paramName: filterKey, submitted: true, hidden:true });
        } else {
          filtersFromRequest[filterKey].push({ label: filterLabel, value:filterValue, key: filterValue, paramName: filterKey, submitted: true, hidden:false });
        }
      }
      <#if filters.keySet().size() gt 0>
         <#list filters.keySet() as filterKey>
            filtersFromRequest['${filterKey}'] = new Array();
           <#list filters.get(filterKey) as filterValue>
             //the title is taken from the link that has the filterKey value as its data-filter attribute
             <#if filterKey == 'MEDIA_TYPE'>
               addFilters(filtersFromRequest,'${filterKey}','${action.getMediaTypeValue(filterValue)}','${action.getFilterTitle(filterKey,filterValue)}');
             <#else>
               addFilters(filtersFromRequest,'${filterKey}','${filterValue}','${action.getFilterTitle(filterKey,filterValue)}');
             </#if>
           </#list>
         </#list>
      </#if>
       $(document).ready(function() {
         var widgetManager = new OccurrenceWidgetManager("<@s.url value='/occurrence/search'/>?",filtersFromRequest,".dropdown-menu",true);
         $("#notifications a").click(function(e) {
            e.preventDefault();
            $(this).hide();
            $("#emails").slideToggle(500);
         });
       <#if action.showDownload()>
         $('a.download_button').bindDialogPopover($('#downloadpopup'));

         $('a.download_submit_button').click(function(event) {
            widgetManager.submit({emails:$('#notify_others').val(),format:$('input:radio[name=downloadFormat]:checked').val()}, "<@s.url value='/occurrence/download'/>?");
         });
         $('#emails').tagit({
           singleField: true,
           singleFieldNode: $('#notify_others'),
           afterTagAdded: function(event, ui) {
             //increasing the padding to extend the div size
             if(!isValidEmail(ui.tagLabel)) {
               $(ui.tag).find('.tagit-label').html('Invalid email adress');
               setTimeout(function (){
                 $('#emails').tagit('removeTagByLabel',ui.tagLabel);
               }, 600);
             } else {
               $('.scrollpane').jScrollPane({ verticalDragMinHeight: 20});
             }
           },
           afterTagRemoved: function(event,ui) {
             $('.scrollpane').jScrollPane({ verticalDragMinHeight: 20});
           }
       });
         function isValidEmail(emailText) {
           var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
           return pattern.test(emailText);
         };
       </#if>
      });
    </script>
    </content>
  </head>
  <body class="search">
    <content tag="infoband">
        <div class="content">
        <h1>Search occurrences</h1>
        <form action="<@s.url value='/occurrence/search'/>" method="GET" id="formSearch" >
          <input id="q" type="text" name="q" value="${q!}" autocomplete="off" placeholder="Search catalog number, occurrenceID, location, descriptions..."/>
        <#list searchRequest.parameters.asMap()?keys as p>
          <#list searchRequest.parameters.get(p) as val>
            <input type="hidden" name="${p?lower_case}" value="${val!}"/>
          </#list>
        </#list>
        </form>
        <br/>
        <h3>Use the filters to customize search results</h3>
        </div>
        <#if action.showDownload()>
        <div class="box">
          <div class="content">
            <ul>
              <li class="single last"><h4>${searchResponse.count!0}</h4>Occurrences</li>
            </ul>
            <a href="#" class="candy_blue_button download_button"><span>Download</span></a>
          </div>
        </div>
        </#if>
    </content>

<article class="occurrence_results">
  <header>
  </header>

  <div class="content" id="content">
    <#assign showOccurrenceKey =  table.hasSummaryField('OCCURRENCE_KEY')>
    <#assign showCatalogNumber =  table.hasSummaryField('CATALOG_NUMBER')>
    <#assign showScientificName =  table.hasSummaryField('SCIENTIFIC_NAME')>
    <#assign showCollectionCode =  table.hasSummaryField('COLLECTION_CODE')>
    <#assign showRecordedBy =  table.hasSummaryField('RECORDED_BY')>
    <#assign showRecordNumber =  table.hasSummaryField('RECORD_NUMBER')>
    <#assign showTypeStatus =  table.hasSummaryField('TYPE_STATUS')>
    <#assign showInstitution =  table.hasSummaryField('INSTITUTION')>
    <#assign showLastInterpreted =  table.hasSummaryField('LAST_INTERPRETED')>
    <#assign showDataset =  table.hasSummaryField('DATASET')>
    <#assign showLocation =  table.hasColumn('LOCATION')>
    <#assign showDate =  table.hasColumn('EVENT_DATE')>
    <#assign showBasisOfRecord =  table.hasColumn('BASIS_OF_RECORD')>
      <div>
    <table class="results" style="float: left;">
      <#if !action.hasErrors()>
        <tr class="header">

          <td class="summary" colspan="${table.summaryColspan}">
            <#if !action.hasSuggestions()><h2>${searchResponse.count} results</h2></#if>
            <#if searchResponse.spellCheckResponse?has_content && searchResponse.spellCheckResponse.suggestions?has_content>
              <div class="spell">
                <span class="spell">Did you mean: </span>
                <#list searchResponse.spellCheckResponse.suggestions?values as suggestion>
                  <#if suggestion.alternatives?has_content>
                    <#list suggestion.alternatives as alternative>
                      <a href="<@s.url value='/occurrence/search'/>${'?' + action.replaceQParam(alternative)}" class="spell" style="font-size: small; display: inline">
                        <b>
                          <i>${alternative}</i>
                        </b>
                      </a>
                    </#list>
                  </#if>
                </#list>
              </div>
            </#if>
          <div class="options">
            <ul>
              <li>
                <a href="#" class="configure" id="configure_link" data-toggle="dropdown"><i></i> Configure</a>
                <div class="dropdown-menu configure filters" id="configure_widget">
                <div class="tip"></div>
                  <h4>Columns</h4>
                  <ul id="occurrence_columns">
                    <li><input type="checkbox" name="columns" value="LOCATION" id="chk-LOCATION" <#if showLocation>checked</#if>/> <label for="chk-LOCATION">Location</label></li>
                    <li><input type="checkbox" name="columns" value="BASIS_OF_RECORD" id="chk-BASIS_OF_RECORD" <#if showBasisOfRecord>checked</#if>/> <label for="chk-BASIS_OF_RECORD">Basis of record</label></li>
                    <li><input type="checkbox" name="columns" value="EVENT_DATE" id="chk-EVENT_DATE" <#if showDate>checked</#if>/> <label for="chk-EVENT_DATE">Date</label></li>
                    <li class="divider"><input type="checkbox" name="columns" value="SUMMARY" id="chk-SUMMARY" class="visibility:hidden;" checked/></li>
                  </ul>
                  <h4>Summary fields</h4>
                  <ul id="summary_fields">
                    <li><input type="checkbox" name="summary" value="OCCURRENCE_KEY" id="chk-OCCURRENCE_KEY" <#if showOccurrenceKey>checked</#if>/> <label for="chk-OCCURRENCE_KEY">Occurrence key</label></li>
                    <li><input type="checkbox" name="summary" value="CATALOG_NUMBER" id="chk-CATALOG_NUMBER" <#if showCatalogNumber>checked</#if>/> <label for="chk-CATALOG_NUMBER">Catalogue number</label></li>
                    <li><input type="checkbox" name="summary" value="COLLECTION_CODE" id="chk-COLLECTION_CODE" <#if showCollectionCode>checked</#if>/> <label for="chk-COLLECTION_CODE">Collection code</label></li>
                    <li><input type="checkbox" name="summary" value="INSTITUTION" id="chk-INSTITUTION" <#if showInstitution>checked</#if>/> <label for="chk-INSTITUTION">Institution</label></li>
                    <li><input type="checkbox" name="summary" value="RECORDED_BY" id="chk-RECORDED_BY" <#if showRecordedBy>checked</#if>/> <label for="chk-RECORDED_BY">Collector name</label></li>
                    <li><input type="checkbox" name="summary" value="RECORD_NUMBER" id="chk-RECORD_NUMBER" <#if showRecordNumber>checked</#if>/> <label for="chk-RECORD_NUMBER">Record number</label></li>
                    <li><input type="checkbox" name="summary" value="SCIENTIFIC_NAME" id="chk-SCIENTIFIC_NAME" <#if showScientificName>checked</#if>/> <label for="chk-SCIENTIFIC_NAME">Scientific name</label></li>
                    <li><input type="checkbox" name="summary" value="DATASET" id="chk-DATASET" <#if showDataset>checked</#if>/> <label for="chk-DATASET">Dataset</label></li>
                    <li><input type="checkbox" name="summary" value="LAST_INTERPRETED" id="chk-LAST_INTERPRETED" <#if showLastInterpreted>checked</#if>/> <label for="chk-LAST_INTERPRETED">Last modified in GBIF</label></li>
                    <li><input type="checkbox" name="summary" value="TYPE_STATUS" id="chk-TYPE_STATUS" <#if showTypeStatus>checked</#if>/> <label for="chk-TYPE_STATUS">Type status</label></li>
                  </ul>
                  <div style="width:100px;" class="buttonContainer"><a href="#" class="button" id="applyConfiguration" style="width:30px;margin:auto"><span>Apply</span></a><div>
                </div>
              </li>
              <li>
                <a href="#" class="filters" data-toggle="dropdown"><i></i> Add a filter</a>

                <div class="dropdown-menu filters">
                  <div class="tip"></div>
                  <ul>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a scientific name..." data-filter="TAXON_KEY"  title="Scientific name" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value species_autosuggest auto_add" class="filter-control">Scientific name</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a country name..." data-filter="COUNTRY" title="Country" data-template-filter="template-simple-filter" data-template-summary="template-filter" class="filter-control" data-input-classes="">Country</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Select a location..." data-filter="GEOMETRY" title="Location" data-template-filter="map-template-filter" data-template-summary="template-summary-location" class="filter-control">Location</a></li>
                    <!--Next li is a place holder to map HAS_COORDINATE to the bounding box widget-->
                    <li style="display:none;"><a tabindex="-1" href="#" data-filter="HAS_COORDINATE" title="Bounding Box" data-template-filter="map-template-filter" data-template-summary="template-filter" class="filter-control">Location</a></li>
                    <li style="display:none;"><a tabindex="-1" href="#" data-filter="HAS_GEOSPATIAL_ISSUE" title="Bounding Box" data-template-filter="map-template-filter" data-template-summary="template-filter" class="filter-control">Location</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a type establishmentMeans..." data-filter="ESTABLISHMENT_MEANS" title="Establishment Means" data-template-filter="template-establishment-means-filter" data-template-summary="template-filter" class="filter-control">Establishment Means</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a name..." data-filter="BASIS_OF_RECORD" title="Basis Of Record" data-template-filter="template-basis-of-record-filter" data-template-summary="template-filter" class="filter-control">Basis of record</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a type status..." data-filter="TYPE_STATUS" title="Type statuses" data-template-filter="template-type-status-filter" data-template-summary="template-filter" class="filter-control">Type status</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a media type..." data-filter="MEDIA_TYPE" title="Multimedia types" data-template-filter="template-media-type-filter" data-template-summary="template-filter" class="filter-control">Multimedia types</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a collector name..." data-filter="RECORDED_BY" title="Collector" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value collector_name_autosuggest auto_add" class="filter-control">Collector</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a record number..." data-filter="RECORD_NUMBER" title="Record number" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value record_number_autosuggest auto_add" class="filter-control">Record number</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a occurrenceID..." data-filter="OCCURRENCE_ID" title="OccurrenceID" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value occurrence_id_autosuggest auto_add" class="filter-control">OccurrenceID</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="" data-filter="EVENT_DATE" title="Collection date" data-template-filter="template-date-compare-filter" data-template-summary="template-filter" class="filter-control" data-input-classes="">Collection date</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a year..." data-filter="YEAR" title="Occurrence year" data-template-filter="template-compare-filter" data-template-summary="template-filter" data-input-classes="value auto_add temporal" class="filter-control">Year</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Select a month..." data-filter="MONTH" title="Occurrence month" data-template-filter="template-month-filter" data-template-summary="template-filter" data-input-classes="value auto_add" class="filter-control">Month</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="" data-filter="LAST_INTERPRETED" title="Last modified in GBIF" data-template-filter="template-date-compare-filter" data-template-summary="template-filter" class="filter-control" data-input-classes="">Last modified in GBIF</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a catalogue number..." data-filter="CATALOG_NUMBER" title="Catalog number" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value catalog_number_autosuggest auto_add" class="filter-control">Catalogue number</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a dataset name..." data-filter="DATASET_KEY" title="Dataset" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value dataset_autosuggest auto_add" class="filter-control">Dataset</a></li>
                    <#--
                    <li><a tabindex="-1" href="#" data-placeholder="Type a continent..." data-filter="CONTINENT" title="Continent" data-template-filter="template-continent-filter" data-template-summary="template-filter" class="filter-control">Continent</a></li>
                    -->
                    <li><a tabindex="-1" href="#" data-placeholder="Type an institution code..." data-filter="INSTITUTION_CODE" title="Institution code" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value institution_code_autosuggest auto_add" class="filter-control">Institution code</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type an collection code..." data-filter="COLLECTION_CODE" title="Collection code" data-template-filter="template-add-filter" data-template-summary="suggestions-template-filter" data-input-classes="value collection_code_autosuggest auto_add" class="filter-control">Collection code</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a country name..." data-filter="PUBLISHING_COUNTRY" title="Publishing country" data-template-filter="template-simple-filter" data-template-summary="template-filter" class="filter-control" data-input-classes="">Publishing country</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type an elevation..." data-filter="ELEVATION" title="Elevation" data-template-filter="template-compare-filter" data-template-summary="template-filter" data-input-classes="value auto_add" class="filter-control">Elevation</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a depth..." data-filter="DEPTH" title="Depth" data-template-filter="template-compare-filter" data-template-summary="template-filter" data-input-classes="value auto_add" class="filter-control">Depth</a></li>
                    <li><a tabindex="-1" href="#" data-placeholder="Type a issue..." data-filter="ISSUE" title="Issues" data-template-filter="template-occurrence-issue-filter" data-template-summary="template-filter" class="filter-control">Issues</a></li>
                  </ul>
                  <input type="hidden" id="nubTaxonomyKey" value="${nubTaxonomyKey}"/>
                </div>
              </li>
          </ul>
        </div>
        </td>
      </tr>
        <#if !action.hasSuggestions() && searchResponse.count gt 0>
          <tr class="results-header">
            <td></td>
            <#if showLocation>
            <td><h4>Location</h4></td>
            </#if>
            <#if showBasisOfRecord>
            <td><h4>Basis of record</h4></td>
            </#if>
            <#if showDate>
            <td><h4>Date</h4></td>
            </#if>
          </tr>
          <#list searchResponse.results as occ>
           <tr class="result">
            <td>
             <a href="<@s.url value='/occurrence/${occ.key?c}'/>">
              <div class="header">
                <#if showOccurrenceKey>
                  <span class="code">${occ.key?c}</span>
                </#if>
                <#assign catalogNumber =  action.termValue('catalogNumber',occ)!>
                <#if showCatalogNumber &&  catalogNumber?has_content><#if showOccurrenceKey>· </#if><span class="catalog" title="${catalogNumber}">Cat. ${common.limit(catalogNumber,40)}</span></#if>
                <#assign recordedBy =  action.termValue('recordedBy',occ)!>
                <#if showRecordedBy && recordedBy?has_content>
                  <div class="code" title="${recordedBy}">Recorded by: ${common.limit(recordedBy,60)}</div>
                </#if>
                <#assign collectionCode =  action.termValue('collectionCode',occ)!>
                <#if showCollectionCode && collectionCode?has_content>
                  <div class="code" title="${collectionCode}">Collection: ${common.limit(collectionCode,60)}</div>
                </#if>
                <#assign institutionCode =  action.termValue('institutionCode',occ)!>
                <#if showInstitution && institutionCode?has_content>
                  <div class="code" title="${institutionCode}">Institution: ${common.limit(institutionCode,60)}</div>
                </#if>
                <#if showLastInterpreted && occ.lastInterpreted?has_content>
                  <div class="code">Last modified in GBIF: ${occ.lastInterpreted?string("yyyy-MM-dd")}</div>
                </#if>
                <#assign recordNumber =  action.termValue('recordNumber',occ)!>
                <#if showRecordNumber && recordNumber?has_content>
                  <div class="code" title="${recordNumber}">Record number: ${common.limit(recordNumber,60)}</div>
                </#if>
                 <#if showTypeStatus && occ.typeStatus?has_content>
                  <div class="code">Type status: ${action.getFilterTitle('typeStatus',occ.typeStatus)!}</div>
                </#if>
              </div>
              <#if showScientificName>
                <#if occ.scientificName?has_content>
                  <a class="title" title="${occ.scientificName}" href="<@s.url value='/occurrence/${occ.key?c}'/>">${common.limit(occ.scientificName,40)}</a>
                <#else>
                  <a class="title-disable" title="Unknown species" href="<@s.url value='/occurrence/${occ.key?c}'/>">Unknown species</a>
                </#if>
              </#if>
              <#if showDataset && occ.datasetKey?has_content>
               <#assign datasetTitle =  action.getDatasetTitle(occ.datasetKey)!>
               <div class="footer" title="${datasetTitle}">Published in ${common.limit(datasetTitle,60)}</div>
              </#if>
             </a>
            </td>
          <#if showLocation>
            <td class="country">
              <#if occ.country?has_content><div class="country">${occ.country.title!}</div></#if>
              <div class="coordinates">
                <#if occ.decimalLatitude?has_content || occ.decimalLongitude?has_content>
                  <#if occ.decimalLatitude?has_content>${occ.decimalLatitude?abs?string("0.00")}${(occ.decimalLatitude >= 0)?then('N','S')}<#else>?</#if>, <#if occ.decimalLongitude?has_content>${occ.decimalLongitude?abs?string("0.00")}${(occ.decimalLongitude >= 0)?then('E','W')}<#else>?</#if>
                <#else>
                  N/A
                </#if>
                <#if occ.elevation?has_content>
                  <div class="code">Elevation: ${occ.elevation}m</div>
                </#if>
                <#if occ.depth?has_content>
                  <div class="code">Depth: ${occ.depth}m</div>
                </#if>
              </div>
            </td>
          </#if>
          <#if showBasisOfRecord>
            <td class="kind">
              <#if occ.basisOfRecord?has_content || occ.decimalLongitude?has_content>
          ${action.getFilterTitle('basisOfRecord',occ.basisOfRecord)!}
        <#else>
         N/A
        </#if>
            </td>
          </#if>
          <#if showDate>
            <td class="date">
              <#if occ.month?has_content || occ.year?has_content>
                <#if occ.month?has_content>${occ.month!?c}<#else>-</#if>
                /
                <#if occ.year?has_content>${occ.year!?c}<#else>-</#if>
              <#else>
                N/A
              </#if>
            </td>
          </#if>
         </tr>
         </#list>
        </#if>
      <#else>
        <tr class="header">
          <td>
            <h2>Error processing your search!</h2>
            <h3>please check your search criteria</h3>
           </td>
        </tr>
        <#list action.getValidationErrors() as error>
          <tr class="result error_summary">
            <td>
              <div>The value <div class="filter-error">"${error.value}"</div> for the parameter "<@s.text name="search.facet.${error.parameter}"/>" is incorrect.</div>
              <br/>
              <div>Try your <a href='${error.urlWithoutError}'>search</a> without this parameter.</div>
             </td>
          </tr>
        </#list>
      </#if>
    </table>
  </div>
  <#if cfg.occurrenceFacetsEnabled>
  <div class="facets" style="padding-top: 20px; text-align:left; margin-right: 4px;vertical-align:top; float:right;display:inline-block; height: 100%;min-height:100%;">
    <h3 style="font-size: 22px; text-transform: none; color: #999999; border-bottom: 1px solid #D8DCE1; padding: 0 0 27px 0;margin: 0 0 10px 0;">Refine your search</h3>
    <div id="resetFacets" data-currentUrl="">
        <input id="resetFacetsButton" value="reset" type="button"/>
    </div>
    <#assign seeAllFacets = ["DATASET_KEY","COUNTRY","MONTH","YEAR"]>
    <#assign facets= ["BASIS_OF_RECORD","TYPE_STATUS","DATASET_KEY","COUNTRY","MONTH","YEAR"]>
    <#include "/WEB-INF/inc/facets.ftl">
  </div>
  </#if>
  <div class="footer" style="float: left;text-align:center; margin: 0 20%;">
    <#if !action.hasSuggestions() && !action.hasErrors()>
      <@macro.pagination page=searchResponse url=currentUrlWithoutPage maxOffset=maxOffset/>
    </#if>
  </div>
  </div>
  <footer></footer>
</article>


<#if searchResponse?has_content && searchResponse.offset gte maxAllowedOffset>
<@common.notice title="Limited paging">
  <p>
    Result paging is limited to ${cfg.maxOccSearchOffset} records.
    Please use more restrictive filters or download all occurrences.
  </p>
</@common.notice>
</#if>

 <#if action.showDownload()>
 <@common.article class="download_ocurrences" title="Download ${searchResponse.count} occurrences from your search">
   <div>
     <a href="#" class="candy_blue_button download_button"><span>Download</span></a>
   </div>
 </@common.article>
 </#if>

  <!-- Filter templates -->
  <#include "/WEB-INF/pages/occurrence/inc/filters.ftl">

  <!-- Download popup -->
  <#include "/WEB-INF/pages/occurrence/inc/downloadpopup.ftl">


  <div class="infowindow" id="waitDialog">
    <div class="light_box">
      <div class="content" >
        <h3>Processing request</h3>
        <p>Wait while your request is processed...
        <img src="<@s.url value='/img/ajax-loader.gif'/>" alt=""/>
      </div>
    </div>
  </div>
</body>
</html>
