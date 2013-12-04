<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>Species API</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
</head>

<#assign tab="species"/>
<#include "/WEB-INF/pages/developer/inc/tabs.ftl" />

<body class="api">


<@api.introArticle>
<div class="left">
    <p>
        This API works against data kept in the GBIF Checklist Bank which
        taxonomically indexes all registered <a href="<@s.url value='/dataset/search?type=CHECKLIST'/>">checklist
        datasets</a> in the GBIF network.
    </p>
    <p>
        For statistics on checklist datasets, you can refer to the <a href="<@s.url value='/developer/registry#dataset_metrics'/>">dataset metrics</a> section of the Registry API.
    </p>
    <p>
        Internally we use a Java web service client for the consumption of these HTTP-based, RESTful web services. It
        may be of interest to those coding against the API, and can be found in the <a
            href="https://code.google.com/p/gbif-ecat/source/browse/checklistbank/trunk/checklistbank-ws-client/"
            target="_blank">checklistbank-ws-client project</a>.
    </p>
</div>
<div class="right">
    <ul>
        <li><a href="#name_usages">Name Usages</a></li>
        <li><a href="#searching">Searching</a></li>
        <li><a href="#parser">Name Parser</a></li>
        <li><a href="#parameters">Query Parameters</a></li>
    </ul>
</div>
</@api.introArticle>


<#-- define some often occurring species defaults -->
<#macro trow url resp httpMethod="GET" respLink="" paging=false params=[]>
<@api.trow url="/species"+url httpMethod=httpMethod resp=resp respLink=respLink paging=paging params=params authRequired=""><#nested /></@api.trow>
</#macro>


<@api.article id="name_usages" title="Working with Name Usages">
  <p>A name usage is the usage of a scientific name according to one
      particular Checklist including the <a href="<@s.url value='/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c'/>">GBIF Taxonomic Backbone</a>
      which is just called <em>nub</em> in this API.
      Name usages from other checklists with names that also exist in the nub will
      have a nubKey that points to the related usage in the backbone.
  </p>

  <@api.apiTable auth=false>
    <@trow url="" paging=true resp="NameUsage Page" respLink="/species?datasetKey=00a0607f-fd7e-4268-9707-0f53aa265f1f&sourceId=ICIMOD_Barsey_Plants_001" params=["language","datasetKey","sourceId","name"]>Lists all name usages across all checklists</@trow>
    <@trow url="/root/{uuid|shortname}" resp="NameUsage Page" respLink="/species/root/66dd0960-2d7d-46ee-a491-87b9adcfe7b1" paging=true >Lists root usages of a checklist</@trow>
    <@trow url="/{int}" resp="NameUsage" respLink="/species/5231190" params=["language"]>Gets the single name usage</@trow>
    <@trow url="/{int}/verbatim" resp="VerbatimNameUsage" respLink="/species/5231190/verbatim">Gets the verbatim name usage</@trow>
    <@trow url="/{int}/name" resp="ParsedName" respLink="/species/5231190/name">Gets the parsed name for a name usage</@trow>
    <@trow url="/{int}/parents" resp="NameUsage List" params=["language"] respLink="/species/5231190/parents">Lists all parent usages for a name usage</@trow>
    <@trow url="/{int}/children" resp="NameUsage Page" paging=true params=["language"] respLink="/species/5231190/children">Lists all direct child usages for a name usage</@trow>
    <@trow url="/{int}/related" resp="NameUsage List" paging=false params=["language","datasetKey"] respLink="/species/5231190/related">Lists all related name usages in other checklists</@trow>
    <@trow url="/{int}/synonyms" resp="NameUsage Page" paging=true params=["language"] respLink="/species/5231190/synonyms">Lists all synonyms for a name usage</@trow>
    <@trow url="/{int}/descriptions" resp="Description Page" paging=true respLink="/species/5231190/descriptions">Lists all descriptions for a name usage</@trow>
    <@trow url="/{int}/distributions" resp="Distribution Page" paging=true respLink="/species/5231190/distributions">Lists all distributions for a name usage</@trow>
    <@trow url="/{int}/images" resp="Image Page" paging=true respLink="/species/5231190/images">Lists all images for a name usage</@trow>
    <@trow url="/{int}/references" resp="Reference Page" paging=true respLink="/species/5231190/references">Lists all references for a name usage</@trow>
    <@trow url="/{int}/species_profiles" resp="SpeciesProfile Page" paging=true respLink="/species/5231190/species_profiles">Lists all species profiles for a name usage</@trow>
    <@trow url="/{int}/vernacular_names" resp="VernacularName Page" paging=true respLink="/species/5231190/vernacular_names">Lists all vernacular names for a name usage</@trow>
    <@trow url="/{int}/type_specimens" resp="TypeSpecimen Page" paging=true respLink="/species/5231190/type_specimens">Lists all type specimens for a name usage</@trow>
  </@api.apiTable>

</@api.article>


<@api.article id="searching" title="Searching Names">
  <p>GBIF provides 4 different ways of finding name usages.
   They differ in their matching behavior, response format and also the actual content covered.
  </p>

  <@api.apiTable auth=false>
    <@trow url="" resp="NameUsage Page" respLink="/species?name=Puma%20concolor" paging=true params=["language","datasetKey","name"] >
      Lists name usages across all or some checklists that share the exact same canonical name, i.e. without authorship.
    </@trow>
    <@trow url="/match" resp="NameUsage Page" respLink="/species/match?verbose=true&kingdom=Plantae&name=Oenante" paging=false params=["rank","name","strict","verbose","kingdom","phylum","class","order","family","genus"]>
      Fuzzy matches scientific names against the GBIF Backbone Taxonomy with the optional classification provided.
      If a classification is provided and strict is not set to true, the default matching will also try to match against these if no direct match is found for the name parameter alone.
    </@trow>
    <@trow url="/search" resp="NameUsage Page" respLink="/species/search?q=Puma&rank=GENUS" paging=true params=["q","datasetKey","rank","highertaxonKey","status","extinct","habitat","threat","nameType","nomenclaturalStatus","hl","facet","facet_only","facet_mincount","facet_multiselect"]>
        Full text search of name usages covering the scientific and vernacular name, the species description, distribution and the entire classification
        across all name usages of all or some checklists. Results are ordered by relevance as this search usually returns a lot of results.</@trow>
    <@trow url="/suggest" resp="NameUsage Page" respLink="/species/suggest?datasetKey=d7dddbf4-2cf0-4f39-9b2a-bb099caae36c&q=Puma%20con" paging=false params=["q","datasetKey","rank"]>
        A quick and simple autocomplete service that returns up to 20 name usages by doing prefix matching against the scientific name.
        Results are ordered by relevance.
    </@trow>
  </@api.apiTable>
</@api.article>


<@api.article id="parser" title="Name Parser">
  <p>GBIF exposes its java based name parser library through our API.
   The service takes one or a list of simple scientific name strings, parses each and returns a list of parsed names.
  </p>

  <@api.apiTable auth=false>
    <@trow url="/parser/name" httpMethod="GET" resp="ParsedName List" respLink="/parser/name?name=Abies%20alba%20Mill.%20sec.%20Markus%20D.&name=Abies%20pinsapo%20var.%20marocana%20(Trab.)%20Ceballos%20%26%20Bolaño%201928" paging=false params=["name"]>
      Parses a scientific name string and returns the ParsedName version of it.
      Accepts multiple parameters each with a single name. Make sure you url encode the names properly.
    </@trow>
    <@trow url="/parser/name" resp="ParsedName List" httpMethod="POST" paging=false params=["name"]>
      Parse list of name strings supplied via one of the following media type encodings:
      <ul>
        <li><em>json</em> array of name strings</li>
        <li><em>plain/text</em> content</li>
        <li><em>multipart/form-data</em> uploaded plain text file</li>
      </ul>
      All text files should be UTF8 encoded with one scientific name per line (please use \n unix new lines).
    </@trow>
  </@api.apiTable>
</@api.article>



<#assign params = {
  "q": "Simple search parameter. The value for this parameter can be a simple word or a phrase. Wildcards can be added to the simple word parameters only, e.g. q=*puma*",
  "language": "default=en or use HTTP header for this",
  "datasetKey": "Filters by the checklist dataset key (a uuid)",
  "sourceId": "Filters by the source identifier",
  "rank": "Filters by taxonomic rank as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/Rank.html' target='_blank'>Rank enum</a>",
  "name": "A scientific name which can be either a case insensitive filter for a canonical namestring, e.g. 'Puma concolor', or an input to the name parser",
  "strict": "If true it (fuzzy) matches only the given name, but never a taxon in the upper classification",
  "verbose": "If true it shows alternative matches which were considered but then rejected",
  "kingdom": "Optional kingdom classification accepting a canonical name.",
  "phylum": "Optional phylum classification accepting a canonical name.",
  "class": "Optional class classification accepting a canonical name.",
  "order": "Optional order classification accepting a canonical name.",
  "family": "Optional family classification accepting a canonical name.",
  "genus": "Optional genus classification accepting a canonical name.",
  "highertaxonKey": "Filters by any of the higher Linnean rank keys. Note this is within the respective checklist and not searching nub keys across all checklists.",
  "status": "Filters by the taxonomic status as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/TaxonomicStatus.html' target='_blank'>TaxonomicStatus enum</a>",
  "extinct": "Filters by extinction status (a boolean, e.g. extinct=true)",
  "habitat": "Filters by the habitat, though currently only as boolean marine or not-marine (i.e. habitat=true means marine, false means not-marine)",
  "threat": "Not yet implemented, but will eventually allow for filtering by a threat status enum",
  "nameType": "Filters by the name type as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/NameType.html' target='_blank'>NameType enum</a>",
  "nomenclaturalStatus": "Not yet implemented, but will eventually allow for filtering by a nomenclatural status enum",
  "facet": "A list of facet names used to retrieve the 100 most frequent values for a field. Allowed facets are: dataset_key, highertaxon_key, rank, status, extinct, habitat, and name_type. Additionally threat and nomenclatural_status are legal values but not yet implemented, so data will not yet be returned for them."
} />



<@api.paramArticle params=params apiName="Species" addSearchParams=true/>


</body>
</html>
