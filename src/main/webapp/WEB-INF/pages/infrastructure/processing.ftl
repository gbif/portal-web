<#import "/WEB-INF/macros/common.ftl" as common>
<html>
<head>
  <title>Data processing</title>
</head>
<#assign tab="processing"/>
<#include "/WEB-INF/pages/infrastructure/inc/infoband.ftl" />


<body>

<@common.article id="processing" title="Occurrence processing" titleRight="Quick links">
  <div class="left">
      <p>
        Every single occurrence record in GBIF goes through a series of processing steps until it becomes available in the GBIF portal.
        Internally the processing is glued together by a messaging system that keeps our processing code independent of each other.
        The process can be devided up into 3 main parts: crawling datasets into fragments, parsing fragments into
        verbatim occurrences and interpreting verbatim values.
      </p>

      <p>
        The outcome of each of these steps is available <a href="<@s.url value='/developer/occurrence#occurrence'/>">through our API</a>.
        Every single occurrence record therefore has a raw fragment, verbatim and interpreted view.
        The corresponding timestamps lastCrawled, lastParsed and lastInterpreted indicate the exact last time each step has run.
      </p>
  </div>
    <div class="right">
      <ul class="tags">
        <li><a href="#fragment">Raw fragments</a></li>
        <li><a href="#verbatim">Verbatim records</a></li>
        <li><a href="#interpreted">Interpreted records</a></li>
        <li><a href="#location">Location interpretation</a></li>
        <li><a href="#taxonomy">Taxonomy interpretation</a></li>
        <li><a href="#temporal">Temporal interpretations</a></li>
        <li><a href="#other">Other interpretations</a></li>
      </ul>
    </div>
</@common.article>


<@common.article id="fragment" title="Raw fragments" titleRight="See also">
    <div class="left">
      <p>
        The very first step is to harvest data from the registered service endpoint in the GBIF registry.
        If multiple services are registered we prefer Darwin Core Archives (Dwc-A).
        On every <a href="http://www.gbif.org/dataset/178ee620-8b79-41e0-8f8a-10f126cf9d82">dataset details page</a>
        you can see all registered services in the external data section of the summary block.
        Similarily they are also included in a dataset detail from our
        <a href="http://api.gbif.org/v1/dataset/178ee620-8b79-41e0-8f8a-10f126cf9d82">JSON API</a>.
      </p>

      <p>
        In addition to Darwin Core Archives GBIF also supports crawling of the XML based BioCASe, TAPIR and DiGIR protocols.
        The outcome of any crawling regardless of its protocol is a set of fragments each representing a single occurrence record
        in it's raw form. In the case of Dwc-A this is a JSON representation of an entire star record,
        i.e. a single core record with all the related extension records attached. In the case of the XML protocols,
        a fragment is the exact piece of XML that we've extracted. Each protocol and content schema (ABCD1.2, ABCD2.06, DwC1.0, DwC1.4, ...)
        therefore still expose their entire content and nature.
        For example here are fragments of <a href="http://www.gbif.org/occurrence/899748029/fragment">ABCD2.06</a>
        and <a href="http://www.gbif.org/occurrence/67008336/fragment">DarwinCore</a>.
      </p>

      <p>
        An important part of fragmenting is to assign a stable GBIF identifier to each fragment.
        This is a delicate process that uses the occurrenceID, catalogNumber, collectionCode and institutionCode in
        combination with the dataset registry key to either mint a new identifier or reuse an existing one if the dataset
        has already been processed before.
      </p>

    </div>
    <div class="right">
      <ul>
        <li><a href="http://www.bgbm.org/tdwg/codata/schema/">ABCD</a></li>
        <li><a href="http://rs.tdwg.org/dwc/">Darwin Core</a></li>
      </ul>
    </div>
</@common.article>

  <@common.article id="verbatim" title="Verbatim records" titleRight="See also">
    <div class="left">
        <p>Each fragment subsequently is then processed into a standard, Darwin Core based form which we call the&nbsp;<a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/model/occurrence/VerbatimOccurrence.html">verbatim representation of an occurrence</a>. This form is very similar to a Darwin Core Archive star record, but it is a bit more structured and we limit the stored extensions to&nbsp;<a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/Extension.html">just 12</a>&nbsp;that we actually understand. At this stage the value of any individual term of a record is still untyped and has the exact verbatim value as found during crawling.</p>
        <p>Parsing has the biggest impact on ABCD fragments as these need to be translated to Darwin Core terms. We are still in the middle of improving the ABCD transformation, that's why you currently will not find all ABCD content in the verbatim version of a record.</p>
      </div>
      <div class="right">
        <ul>
          <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/model/occurrence/VerbatimOccurrence.html">VerbatimOccurrence class</a></li>
        </ul>
      </div>
  </@common.article>

<@common.article id="interpreted" title="Interpreted record" titleRight="See also">
  <div class="left">
    <p>Once all records are available in the standard verbatim form they go through a set of interpretations. These do basic string cleanups but for many important properties we also use strong data typing. For example latitude and longitude values are represented by java doubles and the country, basis of record and many other terms which are based on a controlled vocabulary, are represented by <a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/package-summary.html">fixed enumerations in our java API</a>.</p>

    <h3>Issues</h3>
    <p>There are many things that can go wrong and we continously encounter unexpected data. In order to help us and publishers to improve the data, we flag records with various <a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/OccurrenceIssue.html">issues</a> that we have encountered. This is also very useful for data consumers as you can include these issues as <a href="http://www.gbif-uat.org/occurrence/search?ISSUE=COORDINATE_OUT_OF_RANGE">filters in occurrence searches</a>. Not all issues indicate bad data. Some are merley flagging the fact that GBIF has altered values during processing. On the <a href="http://www.gbif.org/occurrence/236047012#issues">details page of any occurrence record</a> you will see the list of issues in the notice at the very bottom.</p>

    <h3>Darwin Core vs GBIF terms</h3>
    <p>For the interpreted records we use Darwin Core terms as much as possible, but there are some cases when we needed to mint new terms in the <a href="http://gbif.github.io/dwc-api/apidocs/org/gbif/dwc/terms/GbifTerm.html">GBIF namespace</a>. Often these are very GBIF specific things, but in some cases we opted against existing terms in favor of consistency in our API. This is primarily the case for anything related to accuracy. Darwin Core sometimes represents accuracy by providing a minimum and a maximum term, sometimes there is an explicit precision or accuracy term. We decided to be consistent and always use a single term, e.g. depth, accompanied by a matching accuracy term, in this case depthAccuracy.</p>
  </div>
  <div class="right">
    <ul>
      <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/model/occurrence/Occurrence.html">Occurrence class</a></li>
      <li><a href="http://rs.tdwg.org/dwc/terms/index.htm">Darwin Core terms</a></li>
      <li><a href="http://gbif.github.io/dwc-api/apidocs/org/gbif/dwc/terms/GbifTerm.html">GBIF terms</a></li>
      <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/OccurrenceIssue.html">Occurrence issues</a></li>
    </ul>
  </div>
</@common.article>

<@common.article id="location" title="Location interpretation" titleRight="See also">
  <div class="left">
    <h3>Coordinate</h3>
    <p>If geolocated, the interpreted occurrence contains latitude and longitude as decimals for the WGS84 geodetic datum. A <em>coordinateAccuracy</em> in decimal degrees is optionally given if known. We decided not to use dwc:coordinatePrecision as we mean accuracy, not precision. We try to parse and verify the following verbatim terms in the given order to derive a valid WGS84 coordinate:</p>

    <ol><li>dwc:decimalLatitude &amp; dwc:decimalLongitude</li>
      <li>dwc:verbatimLatitude &amp; dwc:verbatimLongitude</li>
      <li>dwc:verbatimCoordinates</li>
    </ol><p>If a geodetic datum is given we then try to interpret the datum and, if different from WGS84, do a <a href="http://gbif.blogspot.com/TODO">reprojection into WGS84</a>. In addition if a literal country was indicated we verify that the coordinate falls within the given country. Frequently lat/lon values are swapped or have negated values which we can also often detect by looking at the expected country.</p>

    <h3>Vertical position</h3>
    <p>For the vertical position of the occurrence Darwin Core provides a <a href="http://rs.tdwg.org/dwc/terms/index.htm#locationindex">wealth of terms</a>. Sadly it is often not clear how to use (min/max)elevationInMeters, (min/max)depthInMeters and (min/max)distanceAboveSurfaceInMeters in more complex cases. We decided to keep it simple and only use elevation and depth together with their accuracy terms to represent the vertical position. The absolute elevation is given as a decimal in meters and should point at the exact location of the occurrence. It is the coordinates vertical position in a 3-dimensional coordiante system. Depth is a relative value indicating the distance to the surface of the earth, whether that's terrestrial or water. We preferred the term depth over distanceAboveSurface as it is very common for sea observations and rarely used for above ground distances.</p>

    <h3>Geography</h3>
    <p>All geographical area terms in Darwin Core are processed, but only country is interpreted as a <a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/Country.html">fixed enumeration</a> matching the <a href="http://www.iso.org/iso/home/standards/country_codes.htm">current ISO countries</a>. When no country but a coordinate was published, we derive a country from the coordinate using our <a href="http://api.gbif.org/v1/geocode/reverse?lat=52.4121&amp;lng=13.3121">reverse geocoding API</a>.</p>
  </div>
  <div class="right">
    <ul>
      <li><a href="http://gbif.blogspot.com/TODO">Datum shift</a></li>
      <li><a href="http://www.iso.org/iso/home/standards/country_codes.htm">ISO countries</a></li>
    </ul>
  </div>
</@common.article>

<@common.article id="taxonomy" title="Taxonomy interpretation" titleRight="See also">
  <div class="left">
      <p>For a hierarchical, taxonomic search and consistent metrics to work all records need to be tied to a single taxonomy. As there is still no single taxonomy existing that covers all known names GBIF builds it's own <a href="http://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c">GBIF backbone</a> on top of the <a href="http://www.catalogueoflife.org/">Catalog of Life</a>. The higher classification above family level exclusively comes from the Catalogue of Life, while lower taxa can be added in an automated way from other taxonomic datasets available through the <a href="http://www.gbif.org/species/">GBIF Checklist Bank</a>.</p>

      <h3>Backbone Matching</h3>
      <p>Every occurrence is assigned a taxonKey which points to the matching taxon in the GBIF backbone. This key is retrieved by querying our <a href="http://www.gbif.org/developer/species#searching">taxon match service</a>, submitting the scientificName, taxonRank, genus, family and all other higher verbatim classification. If the scientificName is not present it will be assembled from the individual name parts if present: genus, specificEpithet and infraspecificEpithet. Having a higher classification qualifying the scientificName helps improving the accuracy of the taxonomic match in two ways, even if it is just the family or even kingdom:</p>

      <ol><li>In case of homonyms or similar spelled names the service has a way to verify the potential matches.</li>
        <li>In case the given scientific name is not (yet) part of the GBIF backbone we can at least match the record to some higher taxon, e.g. the genus.</li>
      </ol><p>Fuzzy name matching, matching to higher or no taxa are issue flags we assign to records.</p>

      <h3>Typification</h3>
      <p>The type status of a specimen is interpreted from <a href="http://rs.tdwg.org/dwc/terms/index.htm#typeStatus">dwc:typeStatus</a> using the <a href="https://github.com/gbif/parsers/blob/master/src/main/java/org/gbif/common/parsers/TypeStatusParser.java">TypeStatusParser</a> according to our <a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/TypeStatus.html">type status vocabulary</a>.</p>
  </div>
  <div class="right">
    <ul>
      <li><a href="http://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c">GBIF backbone</a></li>
      <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/TypeStatus.html">GBIF type status</a></li>
      <li><a href="http://www.catalogueoflife.org/">Catalog of Life</a></li>
    </ul>
  </div>
</@common.article>

<@common.article id="temporal" title="Temporal interpretation" titleRight="See also">
  <div class="left">
      <p>Dates and time can come in various formats, locales and terms in Darwin Core. The majority of dates comes as simple strings, but the recording date might be a complex one defined by multiple terms. In general we use our <a href="https://github.com/gbif/parsers/blob/master/src/main/java/org/gbif/common/parsers/date/DateParseUtils.java">date parser</a> to process verbatim values which prefers the ISO 8601 date format.</p>

      <h3>Simple Date Parsing</h3>
      <p>GBIF processes the following date terms as simple dates:</p>

      <ul><li><em>dc:modified</em>: the date the record has last changed in the source</li>
        <li><em>dateIdentified</em>: the date when the taxonomic identification happened</li>
      </ul><h3>Recording Date</h3>

      <p>Far more important and complex is the task of interpreting the recording date. It can come in either as:</p>

      <ul><li><em>year, month, day</em></li>
        <li><em>eventDate</em></li>
        <li><em>verbatimEventDate</em></li>
      </ul><p>We try to parse the first 2 in any case and compare results if they both exist, flagging mismatches.</p>
  </div>
  <div class="right">
    <ul>
      <li><a href="https://github.com/gbif/parsers/blob/master/src/main/java/org/gbif/common/parsers/date/DateParseUtils.java">DateParseUtils</a></li>
    </ul>
  </div>
</@common.article>

<@common.article id="other" title="Other interpretation" titleRight="See also">
  <div class="left">
      <p>To provide a consistent search experience GBIF interprets a few terms by mapping values to a controlled <a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/package-summary.html">enumeration</a>:</p>

      <ul><li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/BasisOfRecord.html">basisOfRecord</a></li>
        <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/Sex.html">sex</a></li>
        <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/EstablishmentMeans.html">establishmentMeans</a></li>
        <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/LifeStage.html">lifeStage</a></li>
      </ul><p>This is done by <a href="https://github.com/gbif/parsers/tree/master/src/main/java/org/gbif/common/parsers">case insensitive parsers</a> based on a manually maintained dictionary that maps verbatim values we spot to their respective enumeration value.&nbsp;Basic string cleaning and whitespace normalisation is done in any case.&nbsp;</p>

      <h3>Multimedia</h3>
      <p>Please see <a href="http://gbif.blogspot.com/2014/05/multimedia-in-gbif.html">http://gbif.blogspot.com/2014/05/multimedia-in-gbif.html</a></p>
  </div>
  <div class="right">
    <ul>
      <li><a href="http://gbif.blogspot.com/2014/05/multimedia-in-gbif.html">Multimedia in GBIF</a></li>
      <li><a href="http://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/package-summary.html">GBIF enumerations</a></li>
    </ul>
  </div>
</@common.article>

</body>
</html>