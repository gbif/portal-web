package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.common.Identifier;
import org.gbif.api.model.common.Image;
import org.gbif.api.model.occurrence.FactOrMeasurment;
import org.gbif.api.model.occurrence.Occurrence;
import org.gbif.api.model.occurrence.OccurrenceRelation;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.EndpointType;
import org.gbif.api.vocabulary.EstablishmentMeans;
import org.gbif.api.vocabulary.IdentifierType;
import org.gbif.api.vocabulary.LifeStage;
import org.gbif.api.vocabulary.OccurrenceIssue;
import org.gbif.api.vocabulary.Sex;
import org.gbif.api.vocabulary.TypeStatus;
import org.gbif.dwc.terms.DcTerm;
import org.gbif.dwc.terms.DwcTerm;

import java.util.Date;
import java.util.UUID;
import javax.validation.constraints.NotNull;

/**
 * Creates a new mock Occurrence object, and populates all its possible fields.
 * All verbatim fields (for all 10 DwC groups), validations, and interpreted fields are populated.
 */
public class MockOccurrenceFactory {

  private static Occurrence mockOccurrence;

  /**
   * Empty private constructor.
   */
  private MockOccurrenceFactory() {
  }

  static {
    if (mockOccurrence == null) {
      mockOccurrence = new Occurrence();

      // populate verbatim fields
      populateVerbatimFields();

      // populate interpreted fields
      populateInterpretedFields();

      // populate validations
      populateOccurrenceValidations();
    }
  }

  /**
   * Populate all verbatim occurrence fields, including all verbatim values for all DwC terms.
   */
  private static void populateVerbatimFields() {
    // negative key differentiates this mock occurrence record from real ones
    mockOccurrence.setKey(-1000000000);
    mockOccurrence.setDatasetKey(UUID.fromString("4fa7b334-ce0d-4e88-aaae-2e0c138d049e"));
    mockOccurrence.setPublishingOrgKey(UUID.fromString("e2e717bf-551a-4917-bdc9-4fa0f342c530"));
    mockOccurrence.setPublishingCountry(Country.UNITED_STATES);
    mockOccurrence.setProtocol(EndpointType.DWC_ARCHIVE);
    mockOccurrence.setLastCrawled(new Date());

    // populate fields
    populateVerbatimDwcRecordTerms();
    populateVerbatimDwcOccurrenceTerms();
    populateMaterialSampleTerms();
    populateVerbatimDwcEventTerms();
    populateVerbatimDwcLocationTerms();
    populateVerbatimDwcGeologicalConceptTerms();
    populateVerbatimDwcIdentificationTerms();
    populateVerbatimDwcTaxonTerms();

    populateIdentifierList();
    populateMediaList();
    populateFactOrMeasurementList();
    populateOccurrenceRelationList();
  }

  /**
   * Populate all interpreted occurrence fields, including the taxonomic classification.
   */
  private static void populateInterpretedFields() {
    mockOccurrence.setBasisOfRecord(BasisOfRecord.HUMAN_OBSERVATION);
    mockOccurrence.setIndividualCount(1);
    mockOccurrence.setSex(Sex.MALE);
    mockOccurrence.setLifeStage(LifeStage.ADULT);
    mockOccurrence.setEstablishmentMeans(EstablishmentMeans.INTRODUCED);
    mockOccurrence.setTaxonKey(2480985);
    mockOccurrence.setKingdomKey(1);
    mockOccurrence.setPhylumKey(44);
    mockOccurrence.setClassKey(212);
    mockOccurrence.setOrderKey(7191407);
    mockOccurrence.setFamilyKey(5240);
    mockOccurrence.setGenusKey(2480984);
    mockOccurrence.setSubgenusKey(109756028);
    mockOccurrence.setSpeciesKey(2480985);
    mockOccurrence.setScientificName("Caracara cheriway (Jacquin, 1784)");
    mockOccurrence.setKingdom("Animalia");
    mockOccurrence.setPhylum("Chordata");
    mockOccurrence.setClazz("Aves");
    mockOccurrence.setOrder("Falconiformes");
    mockOccurrence.setFamily("Falconidae");
    mockOccurrence.setGenus("Caracara");
    mockOccurrence.setSubgenus("Ichthydium (Furficulichthys) Schwank, 1990");
    mockOccurrence.setSpecies("Caracara cheriway (Jacquin, 1784)");
    mockOccurrence.setDateIdentified(new Date());
    mockOccurrence.setLongitude(-95.86519);
    mockOccurrence.setLatitude(29.91973);
    mockOccurrence.setCoordinateAccuracy(0.1);
    mockOccurrence.setGeodeticDatum("WGS84");
    mockOccurrence.setAltitude(1000);
    mockOccurrence.setAltitudeAccuracy(1);
    mockOccurrence.setDepth(500);
    mockOccurrence.setDepthAccuracy(1);
    mockOccurrence.setContinent(Continent.NORTH_AMERICA);
    mockOccurrence.setCountry(Country.UNITED_KINGDOM);
    mockOccurrence.setStateProvince("California");
    mockOccurrence.setWaterBody("Lake Aloha");
    mockOccurrence.setYear(2012);
    mockOccurrence.setMonth(1);
    mockOccurrence.setDay(30);
    mockOccurrence.setEventDate(new Date());
    mockOccurrence.setTypeStatus(TypeStatus.HOLOTYPE);
    mockOccurrence.setTypifiedName("Caracara cheriway (Jacquin, 1784)");
    mockOccurrence.setModified(new Date());
    mockOccurrence.setLastInterpreted(new Date());
  }

  /**
   * Populate a map of all Occurrence Validations.
   */
  private static void populateOccurrenceValidations() {
    mockOccurrence.getIssues().add(OccurrenceIssue.COORDINATES_OUT_OF_RANGE);
    mockOccurrence.getIssues().add(OccurrenceIssue.COUNTRY_COORDINATE_MISMATCH);
    mockOccurrence.getIssues().add(OccurrenceIssue.PRESUMED_NEGATED_LATITUDE);
    mockOccurrence.getIssues().add(OccurrenceIssue.PRESUMED_NEGATED_LONGITUDE);
    mockOccurrence.getIssues().add(OccurrenceIssue.PRESUMED_SWAPPED_COORDINATE);
    mockOccurrence.getIssues().add(OccurrenceIssue.ZERO_COORDINATE);
  }

  /**
   * Populate all 19 record level terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_RECORD
   */
  private static void populateVerbatimDwcRecordTerms() {
    mockOccurrence.getFields().put(DcTerm.type, "PhysicalObject");
    mockOccurrence.getFields().put(DcTerm.modified, "1963-03-08T14:07-0600");
    mockOccurrence.getFields().put(DcTerm.language, "en" );
    mockOccurrence.getFields().put(DcTerm.rights, "CC0");
    mockOccurrence.getFields().put(DcTerm.rightsHolder, "The Regents of the University of California.");
    mockOccurrence.getFields().put(DcTerm.accessRights, "Not-for-profit use only");
    mockOccurrence.getFields().put(DcTerm.bibliographicCitation, "Ctenomys sociabilis (MVZ 165861)");
    mockOccurrence.getFields().put(DcTerm.references, "http://mvzarctos.berkeley.edu/guid/MVZ:Mamm:165861");
    mockOccurrence.getFields().put(DwcTerm.institutionID, "urn:lsid:biocol.org:institution:34818");
    mockOccurrence.getFields().put(DwcTerm.collectionID, "urn:lsid:biocol.org:col:34818");
    mockOccurrence.getFields().put(DwcTerm.datasetID, "urn:lsid:biocol.org:dataset:123");
    mockOccurrence.getFields().put(DwcTerm.institutionCode, "MVZ");
    mockOccurrence.getFields().put(DwcTerm.collectionCode, "Mammals");
    mockOccurrence.getFields().put(DwcTerm.datasetName, "Grinnell Resurvey Mammals");
    mockOccurrence.getFields().put(DwcTerm.ownerInstitutionCode, "NPS");
    mockOccurrence.getFields().put(DwcTerm.basisOfRecord, "PreservedSpecimen");
    mockOccurrence.getFields().put(DwcTerm.informationWithheld, "Location info not given for endangered species");
    mockOccurrence.getFields().put(DwcTerm.dataGeneralizations, "Coordinates generalized from original coordinates");
    mockOccurrence.getFields().put(DwcTerm.dynamicProperties, "relativeHumidity=28; sampleSizeInKilograms=10");
  }

  /**
   * Populate all occurrence terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_OCCURRENCE
   */
  private static void populateVerbatimDwcOccurrenceTerms() {
    mockOccurrence.getFields().put(DwcTerm.catalogNumber, "88");
    mockOccurrence.getFields().put(DwcTerm.occurrenceID, "urn:catalog:MVZ:Mammals:88");
    mockOccurrence.getFields().put(DwcTerm.occurrenceRemarks, "Found dead on road");
    mockOccurrence.getFields().put(DwcTerm.recordNumber, "OPP 7101");
    mockOccurrence.getFields().put(DwcTerm.recordedBy, "Jane Smith");
    mockOccurrence.getFields().put(DwcTerm.individualID, "Smedley");
    mockOccurrence.getFields().put(DwcTerm.individualCount, "25");
    mockOccurrence.getFields().put(DwcTerm.sex, "female");
    mockOccurrence.getFields().put(DwcTerm.lifeStage, "adult");
    mockOccurrence.getFields().put(DwcTerm.reproductiveCondition, "pregnant");
    mockOccurrence.getFields().put(DwcTerm.behavior, "roosting");
    mockOccurrence.getFields().put(DwcTerm.establishmentMeans, "native");
    mockOccurrence.getFields().put(DwcTerm.occurrenceStatus, "present");
    mockOccurrence.getFields().put(DwcTerm.preparations, "DNA extract");
    mockOccurrence.getFields().put(DwcTerm.disposition, "missing");
    mockOccurrence.getFields().put(DwcTerm.otherCatalogNumbers, "NPS YELLO6778");
    mockOccurrence.getFields().put(DwcTerm.previousIdentifications, "Anthus sp., field ID by G. Iglesias");
    mockOccurrence.getFields().put(DwcTerm.associatedMedia, "http://arctos.database.museum/P7291179.JPG");
    mockOccurrence.getFields().put(DwcTerm.associatedReferences, "http://www.sciencemag.orgcontent/abstract//261");
    mockOccurrence.getFields().put(DwcTerm.associatedOccurrences, "sibling of FMNH:Mammal:1234");
    mockOccurrence.getFields().put(DwcTerm.associatedSequences, "GenBank: U34853.1");
    mockOccurrence.getFields().put(DwcTerm.associatedTaxa, "host: Quercus alba");
  }

  /**
   * Populate all material sample terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#MaterialSample
   */
  private static void populateMaterialSampleTerms() {
    mockOccurrence.getFields().put(DwcTerm.materialSampleID, "MatSam8");
  }

  /**
   * Populate all event terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_EVENT
   */
  private static void populateVerbatimDwcEventTerms() {
    mockOccurrence.getFields().put(DwcTerm.eventID, "Grinnell Resurvey Mammals - EID1");
    mockOccurrence.getFields().put(DwcTerm.samplingProtocol, "mist net");
    mockOccurrence.getFields().put(DwcTerm.samplingEffort, "40 trap-nights");
    mockOccurrence.getFields().put(DwcTerm.eventDate, "2012-01-30");
    mockOccurrence.getFields().put(DwcTerm.eventTime, "14:07-0600");
    mockOccurrence.getFields().put(DwcTerm.startDayOfYear, "1");
    mockOccurrence.getFields().put(DwcTerm.endDayOfYear, "366");
    mockOccurrence.getFields().put(DwcTerm.year, "2012");
    mockOccurrence.getFields().put(DwcTerm.month, "01");
    mockOccurrence.getFields().put(DwcTerm.day, "30");
    mockOccurrence.getFields().put(DwcTerm.verbatimEventDate, "spring 2012");
    mockOccurrence.getFields().put(DwcTerm.habitat, "oak savanna");
    mockOccurrence.getFields().put(DwcTerm.fieldNumber, "RV Sol 87-03-08");
    mockOccurrence.getFields().put(DwcTerm.fieldNotes, "Notes available in Grinnell-Miller Library");
    mockOccurrence.getFields().put(DwcTerm.eventRemarks, "After the recent rains the river is nearly at flood stage");

  }

  /**
   * Populate all location terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_LOCATION
   */
  private static void populateVerbatimDwcLocationTerms() {
    mockOccurrence.getFields().put(DwcTerm.locationID, "L_A:44");
    mockOccurrence.getFields().put(DwcTerm.higherGeographyID, "TGN: 1002002");
    mockOccurrence.getFields().put(DwcTerm.higherGeography, "South America; Argentina");
    mockOccurrence.getFields().put(DwcTerm.continent, "North America");
    mockOccurrence.getFields().put(DwcTerm.waterBody, "Baltic Sea");
    mockOccurrence.getFields().put(DwcTerm.islandGroup, "Alexander Archipelago");
    mockOccurrence.getFields().put(DwcTerm.island, "Isla Victoria");
    mockOccurrence.getFields().put(DwcTerm.country, "USA");
    mockOccurrence.getFields().put(DwcTerm.countryCode, "AR");
    mockOccurrence.getFields().put(DwcTerm.stateProvince, "California");
    mockOccurrence.getFields().put(DwcTerm.county, "Los Lagos");
    mockOccurrence.getFields().put(DwcTerm.municipality, "Holzminden");
    mockOccurrence.getFields().put(DwcTerm.locality, "Bariloche, 25 km NNE via Ruta Nacional 40 (=Ruta 237)");
    mockOccurrence.getFields().put(DwcTerm.verbatimLocality, "25 km NNE Bariloche por R. Nac. 237");
    mockOccurrence.getFields().put(DwcTerm.verbatimElevation, "100-200 m");
    mockOccurrence.getFields().put(DwcTerm.minimumElevationInMeters, "100");
    mockOccurrence.getFields().put(DwcTerm.maximumElevationInMeters, "200");
    mockOccurrence.getFields().put(DwcTerm.verbatimDepth, "100-200 m");
    mockOccurrence.getFields().put(DwcTerm.minimumDepthInMeters, "100");
    mockOccurrence.getFields().put(DwcTerm.maximumDepthInMeters, "200");
    mockOccurrence.getFields().put(DwcTerm.minimumDistanceAboveSurfaceInMeters, "0");
    mockOccurrence.getFields().put(DwcTerm.maximumDistanceAboveSurfaceInMeters, "-1.5");
    mockOccurrence.getFields().put(DwcTerm.locationAccordingTo, "Getty Thesaurus of Geographic Names");
    mockOccurrence.getFields().put(DwcTerm.locationRemarks, "Under water since 2005");
    mockOccurrence.getFields().put(DwcTerm.verbatimCoordinates, "41 05 54S 121 05 34W");
    mockOccurrence.getFields().put(DwcTerm.verbatimLatitude, "41 05 54.03S");
    mockOccurrence.getFields().put(DwcTerm.verbatimLongitude, "121d 10 34 W");
    mockOccurrence.getFields().put(DwcTerm.verbatimCoordinateSystem, "decimal degrees");
    mockOccurrence.getFields().put(DwcTerm.verbatimSRS, "EPSG:4326");
    mockOccurrence.getFields().put(DwcTerm.decimalLatitude, "-41.0983423");
    mockOccurrence.getFields().put(DwcTerm.decimalLongitude, "-121.1761111");
    mockOccurrence.getFields().put(DwcTerm.geodeticDatum, "WGS84");
    mockOccurrence.getFields().put(DwcTerm.coordinateUncertaintyInMeters, "30");
    mockOccurrence.getFields().put(DwcTerm.coordinatePrecision, "0.00001");
    mockOccurrence.getFields().put(DwcTerm.pointRadiusSpatialFit, "1");
    mockOccurrence.getFields().put(DwcTerm.footprintWKT, "POLYGON ((10 20, 11 20, 11 21, 10 21, 10 20))");
    mockOccurrence.getFields().put(DwcTerm.footprintSRS, "PRIMEM[Greenwich,0]");
    mockOccurrence.getFields().put(DwcTerm.footprintSpatialFit, "1");
    mockOccurrence.getFields().put(DwcTerm.georeferencedBy, "Kristina Yamamoto (MVZ)");
    mockOccurrence.getFields().put(DwcTerm.georeferencedDate, "1963-03-08T14:07-0600");
    mockOccurrence.getFields().put(DwcTerm.georeferenceProtocol, "Georeferencing Quick Reference Guide");
    mockOccurrence.getFields().put(DwcTerm.georeferenceSources, "USGS 1:24000 Florence Montana Quad");
    mockOccurrence.getFields().put(DwcTerm.georeferenceVerificationStatus, "Requires verification");
    mockOccurrence.getFields().put(DwcTerm.geologicalContextID, "stratigraphy:1");
  }

  /**
   * Populate all geological concept terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_GEOLOGICALCONTEXT
   */
  private static void populateVerbatimDwcGeologicalConceptTerms() {
    mockOccurrence.getFields().put(DwcTerm.geologicalContextID, "stratigraphy:1");
    mockOccurrence.getFields().put(DwcTerm.earliestEonOrLowestEonothem, "Phanerozoic");
    mockOccurrence.getFields().put(DwcTerm.latestEonOrHighestEonothem, "Proterozoic");
    mockOccurrence.getFields().put(DwcTerm.earliestEraOrLowestErathem, "Cenozoic");
    mockOccurrence.getFields().put(DwcTerm.latestEraOrHighestErathem, "Mesozoic");
    mockOccurrence.getFields().put(DwcTerm.earliestPeriodOrLowestSystem, "Neogene");
    mockOccurrence.getFields().put(DwcTerm.latestPeriodOrHighestSystem, "Quaternary");
    mockOccurrence.getFields().put(DwcTerm.earliestEpochOrLowestSeries, "Ibexian Series");
    mockOccurrence.getFields().put(DwcTerm.latestEpochOrHighestSeries, "Pleistocene");
    mockOccurrence.getFields().put(DwcTerm.earliestAgeOrLowestStage, "Skullrockian");
    mockOccurrence.getFields().put(DwcTerm.latestAgeOrHighestStage, "Boreal");
    mockOccurrence.getFields().put(DwcTerm.lowestBiostratigraphicZone, "N. Atlantic Conodont");
    mockOccurrence.getFields().put(DwcTerm.highestBiostratigraphicZone, "Midcontinent Condonot");
    mockOccurrence.getFields().put(DwcTerm.lithostratigraphicTerms, "shale lithosome");
    mockOccurrence.getFields().put(DwcTerm.group, "Lithosome");
    mockOccurrence.getFields().put(DwcTerm.formation, "House Limestone");
    mockOccurrence.getFields().put(DwcTerm.member, "Hellnmaria Member");
    mockOccurrence.getFields().put(DwcTerm.bed, "hiatus");
  }


  /**
   * Populate all identification terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_IDENTIFICATION
   */
  private static void populateVerbatimDwcIdentificationTerms() {
    mockOccurrence.getFields().put(DwcTerm.identificationID, "ID_ID:2");
    mockOccurrence.getFields().put(DwcTerm.identifiedBy, "John Smith");
    mockOccurrence.getFields().put(DwcTerm.dateIdentified, "1963-03-08T14:07-0600");
    mockOccurrence.getFields().put(DwcTerm.identificationReferences, "Aves del Patagonico. Christie et al. 2004.");
    mockOccurrence.getFields().put(DwcTerm.identificationVerificationStatus, "4");
    mockOccurrence.getFields().put(DwcTerm.identificationRemarks, "Distinguished on the lengths of the uñas.");
    mockOccurrence.getFields().put(DwcTerm.identificationQualifier, "aff. agrifolia var. oxyadenia");
    mockOccurrence.getFields().put(DwcTerm.typeStatus, "holotype of Ctenomys sociabilis. Pearson O. P.");
  }

  /**
   * Populate all taxon terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_TAXON
   */
  private static void populateVerbatimDwcTaxonTerms() {
    mockOccurrence.getFields().put(DwcTerm.taxonID, "8fa58e08-08de-4ac1-b69c-1235340b7001");
    mockOccurrence.getFields().put(DwcTerm.scientificNameID, "urn:lsid:ipni.org:names:37829-1:1.3");
    mockOccurrence.getFields().put(DwcTerm.acceptedNameUsageID , "8fa58e08-08de-4ac1-b69c-1235340b7001");
    mockOccurrence.getFields().put(DwcTerm.parentNameUsageID, "8fa58e08-08de-4ac1-b69c-1235340b7001");
    mockOccurrence.getFields().put(DwcTerm.originalNameUsageID, "http://species.gbif.org/1753");
    mockOccurrence.getFields().put(DwcTerm.nameAccordingToID, "doi:10.1016/S0269-915X(97)80026-2");
    mockOccurrence.getFields().put(DwcTerm.namePublishedInID, "http://hdl.handle.net/10199/7");
    mockOccurrence.getFields().put(DwcTerm.taxonConceptID, "http://hdl.handle.net/10199/7");
    mockOccurrence.getFields().put(DwcTerm.scientificName, "Caracara cheriway");
    mockOccurrence.getFields().put(DwcTerm.acceptedNameUsage, "Caracara cheriway, Jacquin, 1784");
    mockOccurrence.getFields().put(DwcTerm.parentNameUsage, "Caracara");
    mockOccurrence.getFields().put(DwcTerm.originalNameUsage, "Caracara cheriway");
    mockOccurrence.getFields().put(DwcTerm.nameAccordingTo, "Werner Greuter 2008");
    mockOccurrence.getFields().put(DwcTerm.namePublishedIn, "Pearson O. P. 1985. Historia Natural, 5(37):388");
    mockOccurrence.getFields().put(DwcTerm.namePublishedInYear, "1985");
    mockOccurrence.getFields().put(DwcTerm.higherClassification, "Animalia;Chordata;Aves;Falconiformes;Falconidae");
    mockOccurrence.getFields().put(DwcTerm.kingdom, "Animalia");
    mockOccurrence.getFields().put(DwcTerm.phylum, "Chordata");
    mockOccurrence.getFields().put(DwcTerm.class_, "Aves");
    mockOccurrence.getFields().put(DwcTerm.order, "Falconiformes");
    mockOccurrence.getFields().put(DwcTerm.family, "Falconidae");
    mockOccurrence.getFields().put(DwcTerm.genus, "Caracara");
    mockOccurrence.getFields().put(DwcTerm.subgenus, "Caracara");
    mockOccurrence.getFields().put(DwcTerm.specificEpithet, "cheriway");
    mockOccurrence.getFields().put(DwcTerm.infraspecificEpithet, "cheriway");
    mockOccurrence.getFields().put(DwcTerm.taxonRank, "species");
    mockOccurrence.getFields().put(DwcTerm.verbatimTaxonRank, "sp.");
    mockOccurrence.getFields().put(DwcTerm.scientificNameAuthorship, "Jacquin, 1784");
    mockOccurrence.getFields().put(DwcTerm.vernacularName, "American Eagle");
    mockOccurrence.getFields().put(DwcTerm.nomenclaturalCode, "ICBN");
    mockOccurrence.getFields().put(DwcTerm.taxonomicStatus, "accepted");
    mockOccurrence.getFields().put(DwcTerm.nomenclaturalStatus, "nom. ambig.");
    mockOccurrence.getFields().put(DwcTerm.taxonRemarks, "this name is a misspelling in common use");
  }

  /**
   * Populate a list of Identifier with mock values.
   */
  private static void populateIdentifierList() {
    Identifier id1 = new Identifier();
    id1.setIdentifier("http://lsid.tdwg.org/summary/urn:catalog:MVZ:Mammals:88");
    id1.setType(IdentifierType.LSID);
    id1.setTitle("LSID for Record");
    mockOccurrence.getIdentifiers().add(id1);
  }

  /**
   * Populate a list of Image with mock values.
   */
  private static void populateMediaList() {
    Image im1 = new Image();
    im1.setCreated(new Date());
    im1.setCreator("David Remsen");
    im1.setDescription("Female Tachycineta albiventer photographed in the Amazon, Brazil, in November 2010");
    im1.setImage("http://farm6.static.flickr.com/5127/5242866958_98afd8cbce_o.jpg");
    im1.setLicense("http://creativecommons.org/licenses/by-nc-sa/2.0/deed.en");
    im1.setLink("http://en.wikipedia.org/wiki/White-winged_Swallow");
    im1.setPublisher("Encyclopedia of Life");
    im1.setTitle("Andorinha-do-rio (Tachycineta albiventer)");
    mockOccurrence.getMedia().add(im1);
  }

  /**
   * Populate list of FactOrMeasurement with mock values.
   */
  private static void populateFactOrMeasurementList() {
    FactOrMeasurment fom1 = new FactOrMeasurment();
    fom1.setId("MeasurementOrFact:1");
    fom1.setType("tail length");
    fom1.setValue("45");
    fom1.setAccuracy("0.01");
    fom1.setUnit("cm");
    fom1.setDeterminedDate("1963-03-08T14:07-0600");
    fom1.setDeterminedBy("Julie Woodruff");
    fom1.setMethod("minimum convex polygon around burrow entrances");
    fom1.setRemarks("tip of tail missing");
    mockOccurrence.getFacts().add(fom1);
  }

  /**
   * Populate a list of OccurrenceRelation with mock values.
   */
  private static void populateOccurrenceRelationList() {
    OccurrenceRelation or1 = new OccurrenceRelation();
    or1.setId("sub_to_related:1");
    or1.setOccurrenceId(100);
    or1.setRelatedOccurrenceId(900);
    or1.setType("valid synonym of");
    or1.setAccordingTo("Julie Woodruff");
    or1.setEstablishedDate("1963-03-08T14:07-0600");
    or1.setRemarks("mother and offspring collected from the same nest");
    mockOccurrence.getRelations().add(or1);
  }

  /**
   * Return the populated mock Occurrence object.
   *
   * @return the populated mock Occurrence object
   */
  @NotNull
  public static Occurrence getMockOccurrence() {
    return mockOccurrence;
  }

  public static void setMockOccurrence(Occurrence mockOccurrence) {
    MockOccurrenceFactory.mockOccurrence = mockOccurrence;
  }
}
