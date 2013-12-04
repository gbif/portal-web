<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
  <title>GBIF Registry API</title>
  <link rel="stylesheet" href="<@s.url value='/css/bootstrap-tables.css'/>" type="text/css" media="all"/>
</head>

<#assign tab="registry"/>
<#include "/WEB-INF/pages/developer/inc/tabs.ftl" />

<body class="api">


<@api.introArticle>
<div class="left">
    <p>
        This API works against the GBIF Registry, which makes all registered Datasets, Installations, Organizations,
        Nodes, and Networks discoverable.
    </p>
    <p>
        Internally we use a Java web service client for the consumption of these HTTP-based, RESTful web services. It may
        be of interest to those coding against the API, and can be found in the <a
            href="https://code.google.com/p/gbif-registry/source/browse/registry/trunk/registry-ws-client/"
            target="_blank">registry-ws-client project</a>.
    </p>
    <p>
        Please note the old Registry API is still supported, but is now deprecated. Anyone starting new work is strongly
        encouraged to use the new API.
    </p>
</div>
<div class="right">
    <ul>
        <li><a href="#datasets">Datasets</a></li>
        <li><a href="#dataset_search">Dataset Search</a></li>
        <li><a href="#dataset_metrics">Dataset Metrics</a></li>
        <li><a href="#installations">Installations</a></li>
        <li><a href="#organizations">Organizations</a></li>
        <li><a href="#nodes">Nodes</a></li>
        <li><a href="#networks">Networks</a></li>
        <li><a href="#parameters">Query Parameters</a></li>
    </ul>
</div>
</@api.introArticle>



<#-- define some often occurring defaults -->
<#macro trowD url method="GET" auth=false resp="" respLink="" paging=false params=[]>
<@api.trow url="/dataset"+url httpMethod=method authRequired=auth resp=resp respLink=respLink paging=paging params=params><#nested /></@api.trow>
</#macro>

<#macro trowS url resp="DatasetSearchResult" respLink="" paging=false params=[]>
  <@api.trow url="/dataset"+url httpMethod="GET" resp=resp respLink=respLink authRequired="" paging=paging params=params><#nested /></@api.trow>
</#macro>

<#macro trowM url resp="DatasetMetrics" respLink="" paging=false params=[]>
  <@api.trow url=url httpMethod="GET" resp=resp respLink=respLink authRequired="" paging=paging params=params><#nested /></@api.trow>
</#macro>

<#macro trowI url method="GET" auth=false resp="" respLink="" paging=false params=[]>
  <@api.trow url="/installation"+url httpMethod=method authRequired=auth resp=resp respLink=respLink paging=paging params=params><#nested /></@api.trow>
</#macro>

<#macro trowO url method="GET" auth=false resp="" respLink="" paging=false params=[]>
<@api.trow url="/organization"+url httpMethod=method authRequired=auth resp=resp respLink=respLink paging=paging params=params><#nested /></@api.trow>
</#macro>

<#macro trowNo url method="GET" auth=false resp="" respLink="" paging=false params=[]>
  <@api.trow url="/node"+url httpMethod=method authRequired=auth resp=resp respLink=respLink paging=paging params=params><#nested /></@api.trow>
</#macro>

<#macro trowNe url method="GET" auth=false resp="" respLink="" paging=false params=[]>
  <@api.trow url="/network"+url httpMethod=method authRequired=auth resp=resp respLink=respLink paging=paging params=params><#nested /></@api.trow>
</#macro>



<@api.article id="datasets" title="Datasets">
  <p>The dataset API provides CRUD and discovery services for datasets. Its most prominent use on the GBIF portal is to drive the <a href="/dataset">dataset search</a> and dataset pages.</p>
  <@api.apiTable>
    <@trowD url="" resp="Dataset List" respLink="/dataset" paging=true params=["q","country","type","identifier","identifierType"]>Lists all datasets</@trowD>
    <@trowD url="" method="POST" resp="UUID" auth=true>Creates a new dataset</@trowD>
    <@trowD url="/{UUID}" resp="Dataset" respLink="/dataset/4fa7b334-ce0d-4e88-aaae-2e0c138d049e">Gets details for the single dataset</@trowD>
    <@trowD url="/{UUID}" method="PUT" auth=true>Updates the dataset</@trowD>
    <@trowD url="/{UUID}" method="DELETE" auth=true>Deletes the dataset</@trowD>
    <@trowD url="/{UUID}/contact" method="GET" resp="Contact List" respLink="/dataset/4fa7b334-ce0d-4e88-aaae-2e0c138d049e/contact">Lists all contacts for the dataset</@trowD>
    <@trowD url="/{UUID}/contact" method="POST" resp="ID" auth=true>Create and add a dataset contact</@trowD>
    <@trowD url="/{UUID}/contact/{ID}" method="DELETE" auth=true>Deletes a dataset contact with contact identifier {ID}</@trowD>
    <@trowD url="/{UUID}/contact/{ID}" method="PUT" auth=true>Updates a dataset contact with contact identifier {ID}</@trowD>
    <@trowD url="/{UUID}/endpoint" method="GET" resp="Endpoint List" respLink="/dataset/4fa7b334-ce0d-4e88-aaae-2e0c138d049e/endpoint">Lists the dataset endpoints</@trowD>
    <@trowD url="/{UUID}/endpoint" method="POST" resp="ID" auth=true>Creates a dataset endpoint</@trowD>
    <@trowD url="/{UUID}/endpoint/{ID}" method="DELETE" auth=true>Deletes a dataset endpoint with identifier {ID}</@trowD>
    <@trowD url="/{UUID}/identifier" method="GET" resp="Identifier List" respLink="/dataset/4fa7b334-ce0d-4e88-aaae-2e0c138d049e/identifier">Lists the dataset's identifiers</@trowD>
    <@trowD url="/{UUID}/identifier" method="POST" resp="ID" auth=true>Creates a new dataset identifier</@trowD>
    <@trowD url="/{UUID}/identifier/{ID}" method="DELETE" auth=true>Deletes a dataset's identifier with identifier {ID}></@trowD>
    <@trowD url="/{UUID}/tag" method="GET" resp="Tag List" respLink="/dataset/4fa7b334-ce0d-4e88-aaae-2e0c138d049e/tag">Lists all tags for a dataset</@trowD>
    <@trowD url="/{UUID}/tag" method="POST" resp="ID" auth=true>Create and add a dataset tag</@trowD>
    <@trowD url="/{UUID}/tag/{ID}" method="DELETE" auth=true>Deletes the dataset tag with tag identifier {ID}</@trowD>
    <@trowD url="/{UUID}/machinetag" method="GET" resp="Machine Tag List" respLink="/dataset/8575f23e-f762-11e1-a439-00145eb45e9a/machinetag">Lists all machine tags for a dataset</@trowD>
    <@trowD url="/{UUID}/machinetag" method="POST" resp="ID" auth=true>Create and add a dataset machine tag</@trowD>
    <@trowD url="/{UUID}/machinetag/{ID}" method="DELETE">Deletes the dataset machine tag with machine tag identifier {ID}</@trowD>
    <@trowD url="/{UUID}/comment" method="GET" resp="Comment List" respLink="/dataset/4fa7b334-ce0d-4e88-aaae-2e0c138d049e/comment">Lists all comments for a dataset</@trowD>
    <@trowD url="/{UUID}/comment" method="POST" resp="ID" auth=true>Create and add a dataset comment</@trowD>
    <@trowD url="/{UUID}/comment" method="DELETE" auth=true>Deletes the dataset comment with comment identifier {ID}</@trowD>
    <@trowD url="/{UUID}/constituents" method="GET" respLink="/dataset/7ddf754f-d193-4cc9-b351-99906754a03b/constituents" paging=true>Lists the dataset's subdataset constituents (datasets that have a parentDatasetKey equal to the one requested)</@trowD>
    <@trowD url="/{UUID}/document" method="GET" resp="Metadata Document" respLink="/dataset/7ddf754f-d193-4cc9-b351-99906754a03b/document">Gets a GBIF generated EML document overlaying GBIF information with any existing metadata document data.</@trowD>
    <@trowD url="/{UUID}/document" method="POST" resp="ID" auth=true>Pushes a new original source metadata document for a dataset into the registry, replacing any previously existing document of the same type.</@trowD>
    <@trowD url="/{UUID}/metadata" method="GET" resp="Metadata Description List" respLink="/dataset/7ddf754f-d193-4cc9-b351-99906754a03b/metadata" params=["type"]>Lists all metadata descriptions available for a dataset and optionally filters them by document type. The list is sorted by priority with the first result ranking highest. Highest priority in this sense means most relevant for augmenting/updating a dataset, with EML being the most relevant because it is the most informative type.</@trowD>
    <@trowD url="/metadata/{ID}" method="GET" resp="Metadata Description" respLink="/dataset/metadata/1">Get a metadata description by its identifier {ID}</@trowD>
    <@trowD url="/metadata/{ID}/document" method="GET" resp="Metadata Document" respLink="/dataset/metadata/1/document">Gets the actual metadata description's document by its identifier {ID}</@trowD>
    <@trowD url="/metadata/{ID}" method="DELETE" auth=true>Deletes a metadata description entry and its document by its identifier {ID}</@trowD>
    <@trowD url="/deleted" method="GET" respLink="/dataset/deleted" paging=true>Lists all datasets that are marked as deleted</@trowD>
    <@trowD url="/duplicate" method="GET" respLink="/dataset/duplicate" paging=true>Lists all datasets that are marked as a duplicate of another</@trowD>
    <@trowD url="/withNoEndpoint" method="GET" respLink="/dataset/withNoEndpoint" paging=true>Lists all datasets
        (are not sub datasets) having no endpoint</@trowD>
  </@api.apiTable>
</@api.article>

<@api.article id="dataset_search" title="Dataset Search">
  <p>The dataset search API provides search services for datasets.</p>
  <@api.apiTable auth=false >
    <@trowS url="/search" respLink="/dataset/search?q=plant&publishing_country=argentina" paging=true params=["q","country","type","subtype","keyword","owning_org","hosting_org","decade","publishing_country","continent","hl","facet","facet_only","facet_mincount","facet_multiselect"]>Full text search across all datasets.
        Results are ordered by relevance.</@trowS>
    <@trowS url="/suggest" respLink="/dataset/suggest?q=Amazon&type=OCCURRENCE" params=["q","country","type","subtype","keyword","owning_org","hosting_org","decade","publishing_country","continent"]>Search that returns up to 20 matching datasets.
        Results are ordered by relevance.</@trowS>
  </@api.apiTable>

</@api.article>

<@api.article id="dataset_metrics" title="Dataset Metrics">
  <p>The dataset metrics API provides metrics for datasets of type CHECKLIST only.</p>
  <@api.apiTable auth=false>
    <@trowM url="/dataset_metrics/{UUID}" respLink="/dataset_metrics/66dd0960-2d7d-46ee-a491-87b9adcfe7b1">Get various metrics for a checklist.
        Metrics include the number of species, the number of synonyms, counts by rank, counts by vernacular name language, etc.</@trowM>
  </@api.apiTable>

</@api.article>

<@api.article id="installations" title="Installations">
  <p>The installation API provides CRUD and discovery services for installations.</p>
  <@api.apiTable>
    <@trowI url="" resp="Installation List" respLink="/installation" paging=true params=["q","identifier","identifierType"]>Lists all installations</@trowI>
    <@trowI url="" method="POST" resp="UUID" auth=true>Creates a new installation</@trowI>
    <@trowI url="/{UUID}" resp="Installation" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed">Gets details for the single installation</@trowI>
    <@trowI url="/{UUID}" method="PUT" auth=true>Updates the installation</@trowI>
    <@trowI url="/{UUID}" method="DELETE" auth=true>Deletes the installation</@trowI>
    <@trowI url="/{UUID}/contact" method="GET" resp="Contact List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/contact">Lists all contacts for the installation</@trowI>
    <@trowI url="/{UUID}/contact" method="POST" resp="ID" auth=true>Creates and adds an installation contact</@trowI>
    <@trowI url="/{UUID}/contact/{ID}" method="DELETE" auth=true>Deletes an installation contact with contact identifier {ID}</@trowI>
    <@trowI url="/{UUID}/contact/{ID}" method="PUT" auth=true>Updates an installation contact with contact identifier {ID}</@trowI>
    <@trowI url="/{UUID}/endpoint" method="GET" resp="Endpoint List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/endpoint">Lists the installation endpoints</@trowI>
    <@trowI url="/{UUID}/endpoint" method="POST" resp="ID" auth=true>Creates an installation endpoint</@trowI>
    <@trowI url="/{UUID}/endpoint/{ID}" method="DELETE" auth=true>Deletes an installation endpoint with identifier {ID}</@trowI>
    <@trowI url="/{UUID}/identifier" method="GET" resp="Identifier List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/identifier">Lists the installation's identifiers</@trowI>
    <@trowI url="/{UUID}/identifier" method="POST" resp="ID" auth=true>Creates a new installation identifier</@trowI>
    <@trowI url="/{UUID}/identifier/{ID}" method="DELETE" auth=true>Deletes an installation's identifier with identifier {ID}></@trowI>
    <@trowI url="/{UUID}/tag" method="GET" resp="Tag List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/tag">Lists all tags for an installation</@trowI>
    <@trowI url="/{UUID}/tag" method="POST" resp="ID" auth=true>Creates and adds an installation tag</@trowI>
    <@trowI url="/{UUID}/tag/{ID}" method="DELETE" auth=true>Deletes the installation tag with tag identifier {ID}</@trowI>
    <@trowI url="/{UUID}/machinetag" method="GET" resp="Machine Tag List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/machinetag">Lists all machine tags for an installation</@trowI>
    <@trowI url="/{UUID}/machinetag" method="POST" resp="ID" auth=true>Creates and adds an installation machine tag</@trowI>
    <@trowI url="/{UUID}/machinetag/{ID}" method="DELETE">Deletes the installation machine tag with machine tag identifier {ID}</@trowI>
    <@trowI url="/{UUID}/comment" method="GET" resp="Comment List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/comment">Lists all comments for an installation</@trowI>
    <@trowI url="/{UUID}/comment" method="POST" resp="ID" auth=true>Creates and adds an installation comment</@trowI>
    <@trowI url="/{UUID}/comment" method="DELETE" auth=true>Deletes the installation comment with comment identifier {ID}</@trowI>
    <@trowI url="/{UUID}/dataset" method="GET" resp="Dataset List" respLink="/installation/a957a663-2f17-415f-b1c8-5cf6398df8ed/dataset" paging=true>Lists datasets served by the installation</@trowI>
    <@trowI url="/deleted" method="GET" respLink="/installation/deleted" paging=true>Lists the deleted installations</@trowI>
    <@trowI url="/nonPublishing" method="GET" respLink="/installation/nonPublishing" paging=true>Lists the installations serving 0 datasets</@trowI>

  </@api.apiTable>

</@api.article>


<@api.article id="organizations" title="Organizations">
  <p>The organization API provides CRUD and discovery services for organizations. Its most prominent use on the GBIF portal is to drive the <a href="/publisher/search">data publisher search</a>.</p>
  <@api.apiTable>
    <@trowO url="" resp="Organization List" respLink="/organization" paging=true params=["q","country","identifier","identifierType"]>Lists all organizations</@trowO>
    <@trowO url="" method="POST" resp="UUID" auth=true>Creates a new organization</@trowO>
    <@trowO url="/{UUID}" resp="Organization" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530">Gets details for the single organization</@trowO>
    <@trowO url="/{UUID}" method="PUT" auth=true>Updates the organization</@trowO>
    <@trowO url="/{UUID}" method="DELETE" auth=true>Deletes the organization</@trowO>
    <@trowO url="/{UUID}/contact" method="GET" resp="Contact List" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/contact">Lists all contacts for the organization</@trowO>
    <@trowO url="/{UUID}/contact" method="POST" resp="ID" auth=true>Creates and adds an organization contact</@trowO>
    <@trowO url="/{UUID}/contact/{ID}" method="DELETE" auth=true>Deletes an organization contact with contact identifier {ID}</@trowO>
    <@trowO url="/{UUID}/contact/{ID}" method="PUT" auth=true>Updates an organization contact with contact identifier {ID}</@trowO>
    <@trowO url="/{UUID}/endpoint" method="GET" resp="Endpoint List" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/endpoint">Lists the organization endpoints</@trowO>
    <@trowO url="/{UUID}/endpoint" method="POST" resp="ID" auth=true>Creates an organization endpoint</@trowO>
    <@trowO url="/{UUID}/endpoint/{ID}" method="DELETE" auth=true>Deletes an organization endpoint with identifier {ID}</@trowO>
    <@trowO url="/{UUID}/identifier" method="GET" resp="Identifier List" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/identifier">Lists the organization's identifiers</@trowO>
    <@trowO url="/{UUID}/identifier" method="POST" resp="ID" auth=true>Creates a new organization identifier</@trowO>
    <@trowO url="/{UUID}/identifier/{ID}" method="DELETE" auth=true>Deletes an organization's identifier with identifier {ID}></@trowO>
    <@trowO url="/{UUID}/tag" method="GET" resp="Tag List" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/tag">Lists all tags for an organization</@trowO>
    <@trowO url="/{UUID}/tag" method="POST" resp="ID" auth=true>Creates and adds an organization tag</@trowO>
    <@trowO url="/{UUID}/tag/{ID}" method="DELETE" auth=true>Deletes the organization tag with tag identifier {ID}</@trowO>
    <@trowO url="/{UUID}/machinetag" method="GET" resp="Machine Tag List" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/machinetag">Lists all machine tags for an organization</@trowO>
    <@trowO url="/{UUID}/machinetag" method="POST" resp="ID" auth=true>Creates and adds an organization machine tag</@trowO>
    <@trowO url="/{UUID}/machinetag/{ID}" method="DELETE">Deletes the organization machine tag with machine tag identifier {ID}</@trowO>
    <@trowO url="/{UUID}/comment" method="GET" resp="Comment List" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/comment">Lists all comments for an organization</@trowO>
    <@trowO url="/{UUID}/comment" method="POST" resp="ID" auth=true>Creates and adds an organization comment</@trowO>
    <@trowO url="/{UUID}/comment" method="DELETE" auth=true>Deletes the organization comment with comment identifier {ID}</@trowO>
    <@trowO url="/{UUID}/hostedDataset" method="GET" resp="Dataset" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/hostedDataset" paging=true>Lists the hosted datasets (datasets hosted by installations hosted by the organization)</@trowO>
    <@trowO url="/{UUID}/ownedDataset" method="GET" resp="Dataset" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/ownedDataset" paging=true>Lists the owned datasets (datasets published by the organization)</@trowO>
    <@trowO url="/{UUID}/installation" method="GET" resp="Installation" respLink="/organization/e2e717bf-551a-4917-bdc9-4fa0f342c530/installation" paging=true>Lists the technical installations hosted by this organization</@trowO>
    <@trowO url="/deleted" method="GET" resp="Organization List" respLink="/organization/deleted" paging=true>Lists the deleted organizations</@trowO>
    <@trowO url="/pending" method="GET" resp="Organization List" respLink="/organization/pending" paging=true>Lists the organizations whose endorsement is pending</@trowO>

    <@trowO url="/nonPublishing" method="GET" resp="Organization List" respLink="/organization/nonPublishing" paging=true>Lists the organizations publishing 0 datasets</@trowO>
  </@api.apiTable>

</@api.article>

<@api.article id="nodes" title="Nodes">
  <p>The node API provides CRUD and discovery services for nodes. Its most prominent use on the GBIF portal is to drive the <a href="/country">country pages</a>.</p>
  <@api.apiTable>
    <@trowNo url="" resp="Node List" respLink="/node" paging=true params=["q","identifier","identifierType"]>Lists all nodes</@trowNo>
    <@trowNo url="" method="POST" resp="UUID" auth=true>Creates a new node</@trowNo>
    <@trowNo url="/{UUID}" resp="Node" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce">Gets details for the single node</@trowNo>
    <@trowNo url="/{UUID}" method="PUT" auth=true>Updates the node</@trowNo>
    <@trowNo url="/{UUID}" method="DELETE" auth=true>Deletes the node</@trowNo>
    <@trowNo url="/{UUID}/organization" method="GET" resp="Organization" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/organization" paging=true>Lists organizations endorsed by the node</@trowNo>
    <@trowNo url="/{UUID}/endpoint" method="GET" resp="Endpoint List" respLink="/node/1f94b3ca-9345-4d65-afe2-4bace93aa0fe/endpoint">Lists the node endpoints</@trowNo>
    <@trowNo url="/{UUID}/endpoint" method="POST" resp="ID" auth=true>Creates a node endpoint</@trowNo>
    <@trowNo url="/{UUID}/endpoint/{ID}" method="DELETE" auth=true>Deletes a node endpoint with identifier {ID}</@trowNo>
    <@trowNo url="/{UUID}/identifier" method="GET" resp="Identifier List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/identifier">Lists the node's identifiers</@trowNo>
    <@trowNo url="/{UUID}/identifier" method="POST" resp="ID" auth=true>Creates a new node identifier</@trowNo>
    <@trowNo url="/{UUID}/identifier/{ID}" method="DELETE" auth=true>Deletes a node's identifier with identifier {ID}></@trowNo>
    <@trowNo url="/{UUID}/tag" method="GET" resp="Tag List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/tag">Lists all tags for a node</@trowNo>
    <@trowNo url="/{UUID}/tag" method="POST" resp="ID" auth=true>Creates and adds a node tag</@trowNo>
    <@trowNo url="/{UUID}/tag/{ID}" method="DELETE" auth=true>Deletes the node tag with tag identifier {ID}</@trowNo>
    <@trowNo url="/{UUID}/machinetag" method="GET" resp="Machine Tag List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/machinetag">Lists all machine tags for a node</@trowNo>
    <@trowNo url="/{UUID}/machinetag" method="POST" resp="ID" auth=true>Creates and adds a node machine tag</@trowNo>
    <@trowNo url="/{UUID}/machinetag/{ID}" method="DELETE">Deletes the node machine tag with machine tag identifier {ID}</@trowNo>
    <@trowNo url="/{UUID}/comment" method="GET" resp="Comment List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/comment">Lists all comments for a node</@trowNo>
    <@trowNo url="/{UUID}/comment" method="POST" resp="ID" auth=true>Creates and adds a node comment</@trowNo>
    <@trowNo url="/{UUID}/comment" method="DELETE" auth=true>Deletes the node comment with comment identifier {ID}</@trowNo>
    <@trowNo url="/pendingEndorsement" method="GET" resp="Organization List" respLink="/node/pendingEndorsement" paging=true>Lists all organizations whose endorsement is pending</@trowNo>
    <@trowNo url="/{UUID}/pendingEndorsement" method="GET" resp="Organization List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/pendingEndorsement" paging=true>Lists all organizations whose endorsement by the node is pending</@trowNo>
    <@trowNo url="/country" method="GET" resp="ISO-CODE List" respLink="/node/country">Lists names of all GBIF member countries</@trowNo>
    <@trowNo url="/activeCountries" method="GET" resp="ISO-CODE List" respLink="/node/country">Lists of all GBIF member countries that are either voting or associate participants</@trowNo>
    <@trowNo url="/country/{ISO-CODE}" method="GET" resp="Node" respLink="/node/country/CO">Gets the country node by ISO 639-1 (2 letter) or ISO 639-2 (3 letter) country code</@trowNo>
    <@trowNo url="/{UUID}/dataset" method="GET" resp="Dataset List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/dataset" paging=true>Lists datasets owned by organizations endorsed by the node</@trowNo>
    <@trowNo url="/{UUID}/installation" method="GET" resp="Installation List" respLink="/node/0909d601-bda2-42df-9e63-a6d51847ebce/installation" paging=true>Lists installations hosted by organizations endorsed by the node</@trowNo>
  </@api.apiTable>

</@api.article>

<@api.article id="networks" title="Networks">
  <p>The network API provides CRUD and discovery services for networks.</p>
  <@api.apiTable>
    <@trowNe url="" resp="Network List" respLink="/network" paging=true params=["q","identifier","identifierType"]>Lists all networks</@trowNe>
    <@trowNe url="" method="POST" resp="UUID" auth=true>Creates a new network</@trowNe>
    <@trowNe url="/{UUID}" resp="Network" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3">Gets details for the single network</@trowNe>
    <@trowNe url="/{UUID}" method="PUT" auth=true>Updates the network</@trowNe>
    <@trowNe url="/{UUID}" method="DELETE" auth=true>Deletes the network</@trowNe>
    <@trowNe url="/{UUID}/contact" method="GET" resp="Contact List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/contact">Lists all contacts for the network</@trowNe>
    <@trowNe url="/{UUID}/contact" method="POST" resp="ID" auth=true>Creates and adds a network contact</@trowNe>
    <@trowNe url="/{UUID}/contact/{ID}" method="DELETE" auth=true>Deletes a network contact with contact identifier {ID}</@trowNe>
    <@trowNe url="/{UUID}/contact/{ID}" method="PUT" auth=true>Updates a network contact with contact identifier {ID}</@trowNe>
    <@trowNe url="/{UUID}/endpoint" method="GET" resp="Endpoint List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/endpoint">Lists the network endpoints</@trowNe>
    <@trowNe url="/{UUID}/endpoint" method="POST" resp="ID" auth=true>Creates a network endpoint</@trowNe>
    <@trowNe url="/{UUID}/endpoint/{ID}" method="DELETE" auth=true>Deletes a network endpoint with identifier {ID}</@trowNe>
    <@trowNe url="/{UUID}/identifier" method="GET" resp="Identifier List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/identifier">Lists the network's identifiers</@trowNe>
    <@trowNe url="/{UUID}/identifier" method="POST" resp="ID" auth=true>Creates a new network identifier</@trowNe>
    <@trowNe url="/{UUID}/identifier/{ID}" method="DELETE" auth=true>Deletes a network's identifier with identifier {ID}></@trowNe>
    <@trowNe url="/{UUID}/tag" method="GET" resp="Tag List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/tag">Lists all tags for a network</@trowNe>
    <@trowNe url="/{UUID}/tag" method="POST" resp="ID" auth=true>Creates and adds a network tag</@trowNe>
    <@trowNe url="/{UUID}/tag/{ID}" method="DELETE" auth=true>Deletes the network tag with tag identifier {ID}</@trowNe>
    <@trowNe url="/{UUID}/machinetag" method="GET" resp="Machine Tag List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/machinetag">Lists all machine tags for the network</@trowNe>
    <@trowNe url="/{UUID}/machinetag" method="POST" resp="ID" auth=true>Creates and adds a network machine tag</@trowNe>
    <@trowNe url="/{UUID}/machinetag/{ID}" method="DELETE">Deletes the network machine tag with machine tag identifier {ID}</@trowNe>
    <@trowNe url="/{UUID}/comment" method="GET" resp="Comment List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/comment">Lists all comments for the network</@trowNe>
    <@trowNe url="/{UUID}/comment" method="POST" resp="ID" auth=true>Creates and adds a network comment</@trowNe>
    <@trowNe url="/{UUID}/comment" method="DELETE" auth=true>Deletes the network comment with comment identifier {ID}</@trowNe>
    <@trowNe url="/{UUID}/constituents" method="GET" resp="Dataset List" respLink="/network/7ddd1f14-a2b0-4838-95b0-785846f656f3/constituents" paging=true>Lists dataset constituents of the network</@trowNe>
    <@trowNe url="/{UUID}/constituents" method="POST" resp="" auth=true>Adds an existing dataset to the list of constituents of a network</@trowNe>
    <@trowNe url="/{UUID}/constituents" method="DELETE" resp="ID" auth=true>Deletes an existing constituent dataset from a network</@trowNe>
  </@api.apiTable>
</@api.article>


<#assign params = {
  "q": "Simple search parameter. The value for this parameter can be a simple word or a phrase. Wildcards can be added to the simple word parameters only, e.g. q=*puma*",
  "country": "Filters by country as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/Country.html' target='_blank'>Country enum</a>, e.g. country=CANADA. Not yet implemented for use with dataset search, but will eventually search on the countries within the geospatial coverage of the dataset.",
  "type": "For datasets, filters by dataset type as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/DatasetType.html' target='_blank'>DatasetType enum</a>. For metadata documents, filters by the metadata type as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/MetadataType.html' target='_blank'>MetadataType enum</a>",
  "identifier": "The value for this parameter can be a simple string or integer, e.g. identifier=120",
  "identifierType": "Used in combination with the identifier parameter to filter identifiers by identifier type as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/IdentifierType.html' target='_blank'>IdentifierType enum</a>",
  "subtype": "Not yet implemented, but will eventually allow filtering of datasets by their dataset subtype as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/DatasetSubtype.html' target='_blank'>DatasetSubtype enum</a>.",
  "keyword": "Filters datasets by a case insensitive plain text keyword. The search is done on the merged collection of tags, the dataset keywordCollections and temporalCoverages.",
  "owning_org": "Filters datasets by their owning organization UUID key",
  "hosting_org": "Filters datasets by their hosting organization UUID key",
  "decade": "Filters datasets by their temporal coverage broken down to decades. Decades are given as a full year, e.g. 1880, 1960, 2000, etc, and will return datasets wholly contained in the decade as well as those that cover the entire decade or more. Facet by decade to get the break down, e.g. <a href='http://api.gbif.org/dataset/search?facet=DECADE&facet_only=true' target='_blank'>/search?facet=DECADE&facet_only=true</a>",
  "publishing_country": "Filters datasets by their owining organization's country as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/Country.html' target='_blank'>Country enum</a>",
  "continent": "Not yet implemented, but will eventually allow filtering datasets by their continent(s) as given in our <a href='http://builds.gbif.org/view/Common/job/gbif-api/site/apidocs/org/gbif/api/vocabulary/Continent.html' target='_blank'>Continent enum</a>.",
  "facet": "A list of facet names used to retrieve the 100 most frequent values for a field. Allowed facets are: type, keyword, owning_org, hosting_org, decade, and publishing_country. Additionally subtype and country are legal values but not yet implemented, so data will not yet be returned for them."
} />


<@api.paramArticle params=params apiName="Registry" addSearchParams=true />


</body>
</html>
