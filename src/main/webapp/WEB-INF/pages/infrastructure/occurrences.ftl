<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Occurrences</title>
</head>
<#assign tab="occurrences"/>
<#include "/WEB-INF/pages/infrastructure/inc/infoband.ftl" />


<body>

<@common.article id="about" title="About" titleRight="Quick links">
  <div class="left">
    <p>The occurrence publishing network spans across 500+ publishing institutions globally.  Data holders manage content in either spreadsheets or databases 
    and then use specific publishing tools to expose those data for querying and access over the internet.  The existence of the dataset and the technical protocols
    required to access the data are entered into the GBIF registry.</p>  
    <p>Aggregators such as the GBIF global portal and national GBIF data portals, crawl datasets and build sophisticated indexes to allow users to efficiently 
    search and access content across datasets.</p>
    <p>This page briefly describes the architecture and operations performed in the global GBIF portal when crawling and indexing occurrence data for user search and download.</p>    
  </div>
  <div class="right">
    <ul>
      <li><a href="#componentArchitecture" title="GBIF portal occurrence architecture">GBIF portal occurrence architecture</a></li>
    </ul>
  </div>
</@common.article>



<@common.article id="componentArchitecture" title="Component architecture"  titleRight="See also" class="rte">
  <div class="left">
<p>The architecture is designed to be an efficient distributed crawling and processing system, with decoupling of components.  The primary goals of
the architecture design were to ensure rapid processing of data to reduce latencies between publisher changes and global discovery, and to be flexible 
enough that components can be swapped out or updated as needed.  The architecture is best explained with 2 example use cases.</p>
<p>
<ol>
<ol>
  <li>by describing the sequential set of steps that occur when a new dataset is registered into the <a href="registry">registry</a>. 
  This use case was chosen since a newly registered dataset triggers action on all components of the architecture.</li>
  <li>by describing the process that occurs when a user searches and chooses to download content.</li>
</ol>
</ol>
</p>  
<p>The following illustrates the core components of the occurrence architecture which will be explained as we progress through the examples.  Core to all of this is the 
distributed <a href="http://hadoop.apache.org/" title="Hadoop project" target="_blank">Apache Hadoop</a> cluster, which provides distributed redundant copies of content and parallelized processing capabilities.</p>
<p><img src="<@s.url value='/img/infrastructure/occurrence.png'/>"/></p>

<h3>Use case: A newly registered dataset</h3>
<ul class="indent">
  <li>The dataset is registered in the registry.  The technical access point information is associated with the dataset, including the URL and protocol 
  required to access it.</li>
  <li>The registry emits a message onto the shared messaging bus (<a href="http://www.rabbitmq.com/" title="RabbitMQ project" target="_blank">RabbitMQ</a>) that a dataset is ready to 
  be crawled. Note that the crawl scheduling component might also emit this message when a dataset is ready to be re-crawled which happens periodically</li>
  <li>There are many crawlers that can run concurrently, and are controlled by the crawler coordinator.  The coordinator receives the message from the registry and will manage
  crawl resources to initiate the crawl.  At this point, locks (<a href="http://zookeeper.apache.org/" title="ZooKeeper project" target="_blank">Apache ZooKeeper</a>) are taken out to ensure 
  that concurrent crawlers do not over eagerly crawl an endpoint.  Additionally, shared counters will be configured, which will be updated at every subsequent stage of processing to allow for overall 
  monitoring, and the ability to determine when a crawl is complete across all components.</li>
  <li>Some of the data protocols GBIF support require paging (e.g. <a href="http://www.tdwg.org/standards/449/" title="TAPIR" target="_blank">TAPIR</a>, <a href="http://www.biocase.org/" title="BioCASe" target="_blank">BioCASe</a>), while others support a single HTTP request (e.g. <a href="http://www.gbif.org/orc/?doc_id=2816&l=en" title="DarwinCore Archive" target="_blank">Darwin Core Archives</a>).  In both cases, for each artifact retrieved (a page or the full dataset) 
  the crawler harvests the content, persists it to disk and emits a message declaring it is ready to process.  Shared counters are maintained (<a href="http://zookeeper.apache.org/" title="ZooKeeper project" 
  target="_blank">Apache ZooKeeper</a>) about the progress.  For <a href="http://www.gbif.org/orc/?doc_id=2816&l=en" title="DarwinCore Archive" target="_blank">Darwin Core Archives</a>, validation will occur to ensure the archive is suitable for further processing</li>
  <li>For each artifact, a processor will extract single occurrence records, emitting a message for each record harvested.  This is received and a processor inspects the record for its identity 
  (e.g. <a href="http://rs.tdwg.org/dwc/terms/#occurrenceID" target="_blank">dwc:occurrenceID</a> or using the <a href="http://rs.tdwg.org/dwc/terms/#institutionCode" target="_blank">dwc:institutionCode</a>, <a href="http://rs.tdwg.org/dwc/terms/#collectionCode" target="_blank">dwc:collectionCode</a> and <a href="http://rs.tdwg.org/dwc/terms/#catalogNumber" target="_blank">dwc:catalogNumber</a>).  In this case the records are all new and the fragment for the record will be inserted into <a href="http://hbase.apache.org/" title="HBase project" 
  target="_blank">Apache HBase</a>.  This is the raw content as harvested, so might be a fragment of XML for some protocols. A message is emitted and counters updated</li>
  <li>A processor will receive the message and the raw view of the record is <em>normalized</em> into separate fields of the DarwinCore with as little interpretation as possible.  A message is emitted declaring the record is normalized 
  and a processor will start interpreting content and applying quality control.  This includes:
  <ol>
    <li>Ensuring all basis of record values align to a vocabulary</li>
    <li>Ensuring all coordinates look sensible compared to the other fields present</li>
    <li>Making inference of (e.g.) country, where coordinates exist but no country is stated</li>
    <li>Aligning the record to the GBIF Backbone taxonomy using the <a href="../../developer/species#searching" target="_blank">name lookup web service</a></li>
  </ol>
  Once processing is complete, a message is emitted to declare the record is finished, and counters are updated.  The crawler coordinator monitoring the counters will observe this, and will write the result of the crawl
  to the registry for future auditing, and reporting on crawling history when it determines from the counters that all messages are processed.
  </li>
  <li>In order to support real time search, and various views on the portal such as maps and statistics specific data structures are maintained.  The newly created record messages will be observed by
  <ol>
    <li>The <a href="http://lucene.apache.org/solr/" title="SOLR project" target="_blank">Apache SOLR</a> index updaters will update the index</li>
    <li>The maps will be computed for all supported views (e.g. dataset, publisher, taxa etc).  See map web services</li>
    <li>The data cube supporting the various metrics will be updated with new counts.  See the metrics web services</li>    
  </ol>
  </li>
</ul>
<p>&nbsp</p>
<h3>Use case: User search and download</h3>
<ul class="indent">
  <li>The user performs a search in the portal and chooses the download button</li>
  <li>A download workflow is initiated, which is orchestrated by the Hadoop workflow manager provided by <a href="http://oozie.apache.org/" title="Oozie project" target="_blank">Apache Oozie</a></li>
  <li>The workflow will follow the following process:
  <ol>
    <li>A query against <a href="http://lucene.apache.org/solr/" title="SOLR project" target="_blank">Apache SOLR</a> is used to get the count of records to download</li>
    <li>If the result size is below a threshold, a paging process iterates over results from SOLR, retrieving the occurrence ids. For each ID, a "get by key" operation against HBase 
    provides the record details, which are written into the output file.</li>
    <li>If the result size is above the threshold, a Hadoop <a href="http://en.wikipedia.org/wiki/MapReduce" target="_blank">MapReduce</a> based process is initiated. 
    <a href="http://hive.apache.org/" title="Hive project" target="_blank">Apache Hive</a> is used to provide a "SQL like" query language, which iterates over the HBase content
    to produce the output file</li>
    <li>Once complete, subsequent workflow stages run which produce the necessary citation and metadata files by using the <a href="../../developer/registry">Registry API</a></li>
    <li>Finally all pieces are converted into a <a href="http://www.gbif.org/orc/?doc_id=2816&l=en" target="_blank">Darwin Core Archive</a> by zipping together.  For large datasets
    this is the most time consuming stage, as the Zip format is very slow to produce as it cannot be parallelized, but is the most compatible.</li>
  </ol>
  
  </li>
</ul>


  </div>
  <div class="right">
    <ul>
      <li><a href="http://hadoop.apache.org/" title="Hadoop project" target="_blank">Apache Hadoop</a></li>
      <li><a href="http://hbase.apache.org/" title="HBase project" target="_blank">Apache HBase</a></li>
      <li><a href="http://lucene.apache.org/solr/" title="SOLR project" target="_blank">Apache SOLR</a></li>
      <li><a href="http://zookeeper.apache.org/" title="ZooKeeper project" target="_blank">Apache ZooKeeper</a></li>
      <li><a href="http://www.rabbitmq.com/" title="RabbitMQ project" target="_blank">RabbitMQ</a></li>
      <li><a href="http://oozie.apache.org/" title="Oozie project" target="_blank">Apache Oozie</a></li>
      <li><a href="http://hive.apache.org/" title="Hive project" target="_blank">Apache Hive</a></li>
      <li><a href="http://www.tdwg.org/standards/449/" title="TAPIR" target="_blank">TAPIR</a></li>
      <li><a href="http://www.biocase.org/" title="BioCASe" target="_blank">BioCASe</a></li>
      <li><a href="http://www.gbif.org/orc/?doc_id=2816&l=en" title="DarwinCore Archive" target="_blank">Darwin Core Archives</a></li>
      <li><a href="http://rs.tdwg.org/dwc/terms/" title="Darwin Core" target="_blank">Darwin Core Terms</a></li>
    </ul>
  </div>
</@common.article>


</body>
</html>