package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.common.Identifier;
import org.gbif.api.model.common.MediaObject;
import org.gbif.api.model.occurrence.FactOrMeasurment;
import org.gbif.api.model.occurrence.Occurrence;
import org.gbif.api.model.occurrence.OccurrenceRelation;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.EndpointType;
import org.gbif.api.vocabulary.EstablishmentMeans;
import org.gbif.api.vocabulary.Extension;
import org.gbif.api.vocabulary.IdentifierType;
import org.gbif.api.vocabulary.LifeStage;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.api.vocabulary.OccurrenceIssue;
import org.gbif.api.vocabulary.Sex;
import org.gbif.api.vocabulary.TypeStatus;
import org.gbif.dwc.terms.DcTerm;
import org.gbif.dwc.terms.DwcTerm;
import org.gbif.dwc.terms.Term;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.validation.constraints.NotNull;

import com.google.common.base.Throwables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

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

      // populate extensions
      populateExtensions();

      // populate validations
      populateOccurrenceValidations();
    }
  }

  private static void populateExtensions() {
    populateIdentifierList();
    populateMediaList();
    populateFactOrMeasurementList();
    populateOccurrenceRelationList();
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

    populateVerbatimExtensions();
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
    mockOccurrence.setDecimalLongitude(-95.86519);
    mockOccurrence.setDecimalLatitude(29.91973);
    mockOccurrence.setCoordinateAccuracy(0.1);
    mockOccurrence.setElevation(1000.6);
    mockOccurrence.setElevationAccuracy(1.6);
    mockOccurrence.setDepth(500.6);
    mockOccurrence.setDepthAccuracy(1.6);
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
    mockOccurrence.getIssues().add(OccurrenceIssue.COORDINATE_OUT_OF_RANGE);
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
    mockOccurrence.getVerbatimFields().put(DcTerm.type, "PhysicalObject");
    mockOccurrence.getVerbatimFields().put(DcTerm.modified, "1963-03-08T14:07-0600");
    mockOccurrence.getVerbatimFields().put(DcTerm.language, "en" );
    mockOccurrence.getVerbatimFields().put(DcTerm.rights, "CC0");
    mockOccurrence.getVerbatimFields().put(DcTerm.rightsHolder, "The Regents of the University of California.");
    mockOccurrence.getVerbatimFields().put(DcTerm.accessRights, "Not-for-profit use only");
    mockOccurrence.getVerbatimFields().put(DcTerm.bibliographicCitation, "Ctenomys sociabilis (MVZ 165861)");
    mockOccurrence.getVerbatimFields().put(DcTerm.references, "http://mvzarctos.berkeley.edu/guid/MVZ:Mamm:165861");
    mockOccurrence.getVerbatimFields().put(DwcTerm.institutionID, "urn:lsid:biocol.org:institution:34818");
    mockOccurrence.getVerbatimFields().put(DwcTerm.collectionID, "urn:lsid:biocol.org:col:34818");
    mockOccurrence.getVerbatimFields().put(DwcTerm.datasetID, "urn:lsid:biocol.org:dataset:123");
    mockOccurrence.getVerbatimFields().put(DwcTerm.institutionCode, "MVZ");
    mockOccurrence.getVerbatimFields().put(DwcTerm.collectionCode, "Mammals");
    mockOccurrence.getVerbatimFields().put(DwcTerm.datasetName, "Grinnell Resurvey Mammals");
    mockOccurrence.getVerbatimFields().put(DwcTerm.ownerInstitutionCode, "NPS");
    mockOccurrence.getVerbatimFields().put(DwcTerm.basisOfRecord, "PreservedSpecimen");
    mockOccurrence.getVerbatimFields().put(DwcTerm.informationWithheld, "Location info not given for endangered species");
    mockOccurrence.getVerbatimFields().put(DwcTerm.dataGeneralizations, "Coordinates generalized from original coordinates");
    mockOccurrence.getVerbatimFields().put(DwcTerm.dynamicProperties, "relativeHumidity=28; sampleSizeInKilograms=10");
  }

  /**
   * Populate all occurrence terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_OCCURRENCE
   */
  private static void populateVerbatimDwcOccurrenceTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.catalogNumber, "88");
    mockOccurrence.getVerbatimFields().put(DwcTerm.occurrenceID, "urn:catalog:MVZ:Mammals:88");
    mockOccurrence.getVerbatimFields().put(DwcTerm.occurrenceRemarks, "Found dead on road");
    mockOccurrence.getVerbatimFields().put(DwcTerm.recordNumber, "OPP 7101");
    mockOccurrence.getVerbatimFields().put(DwcTerm.recordedBy, "Jane Smith");
    mockOccurrence.getVerbatimFields().put(DwcTerm.individualID, "Smedley");
    mockOccurrence.getVerbatimFields().put(DwcTerm.individualCount, "25");
    mockOccurrence.getVerbatimFields().put(DwcTerm.sex, "female");
    mockOccurrence.getVerbatimFields().put(DwcTerm.lifeStage, "adult");
    mockOccurrence.getVerbatimFields().put(DwcTerm.reproductiveCondition, "pregnant");
    mockOccurrence.getVerbatimFields().put(DwcTerm.behavior, "roosting");
    mockOccurrence.getVerbatimFields().put(DwcTerm.establishmentMeans, "native");
    mockOccurrence.getVerbatimFields().put(DwcTerm.occurrenceStatus, "present");
    mockOccurrence.getVerbatimFields().put(DwcTerm.preparations, "DNA extract");
    mockOccurrence.getVerbatimFields().put(DwcTerm.disposition, "missing");
    mockOccurrence.getVerbatimFields().put(DwcTerm.otherCatalogNumbers, "NPS YELLO6778");
    mockOccurrence.getVerbatimFields().put(DwcTerm.previousIdentifications, "Anthus sp., field ID by G. Iglesias");
    mockOccurrence.getVerbatimFields().put(DwcTerm.associatedMedia, "http://arctos.database.museum/P7291179.JPG");
    mockOccurrence.getVerbatimFields().put(DwcTerm.associatedReferences, "http://www.sciencemag.orgcontent/abstract//261");
    mockOccurrence.getVerbatimFields().put(DwcTerm.associatedOccurrences, "sibling of FMNH:Mammal:1234");
    mockOccurrence.getVerbatimFields().put(DwcTerm.associatedSequences, "GenBank: U34853.1");
    mockOccurrence.getVerbatimFields().put(DwcTerm.associatedTaxa, "host: Quercus alba");
  }

  /**
   * Populate all material sample terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#MaterialSample
   */
  private static void populateMaterialSampleTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.materialSampleID, "MatSam8");
  }

  /**
   * Populate all event terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_EVENT
   */
  private static void populateVerbatimDwcEventTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.eventID, "Grinnell Resurvey Mammals - EID1");
    mockOccurrence.getVerbatimFields().put(DwcTerm.samplingProtocol, "mist net");
    mockOccurrence.getVerbatimFields().put(DwcTerm.samplingEffort, "40 trap-nights");
    mockOccurrence.getVerbatimFields().put(DwcTerm.eventDate, "2012-01-30");
    mockOccurrence.getVerbatimFields().put(DwcTerm.eventTime, "14:07-0600");
    mockOccurrence.getVerbatimFields().put(DwcTerm.startDayOfYear, "1");
    mockOccurrence.getVerbatimFields().put(DwcTerm.endDayOfYear, "366");
    mockOccurrence.getVerbatimFields().put(DwcTerm.year, "2012");
    mockOccurrence.getVerbatimFields().put(DwcTerm.month, "01");
    mockOccurrence.getVerbatimFields().put(DwcTerm.day, "30");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimEventDate, "spring 2012");
    mockOccurrence.getVerbatimFields().put(DwcTerm.habitat, "oak savanna");
    mockOccurrence.getVerbatimFields().put(DwcTerm.fieldNumber, "RV Sol 87-03-08");
    mockOccurrence.getVerbatimFields().put(DwcTerm.fieldNotes, "Notes available in Grinnell-Miller Library");
    mockOccurrence.getVerbatimFields().put(DwcTerm.eventRemarks, "After the recent rains the river is nearly at flood stage");

  }

  /**
   * Populate all location terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_LOCATION
   */
  private static void populateVerbatimDwcLocationTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.locationID, "L_A:44");
    mockOccurrence.getVerbatimFields().put(DwcTerm.higherGeographyID, "TGN: 1002002");
    mockOccurrence.getVerbatimFields().put(DwcTerm.higherGeography, "South America; Argentina");
    mockOccurrence.getVerbatimFields().put(DwcTerm.continent, "North America");
    mockOccurrence.getVerbatimFields().put(DwcTerm.waterBody, "Baltic Sea");
    mockOccurrence.getVerbatimFields().put(DwcTerm.islandGroup, "Alexander Archipelago");
    mockOccurrence.getVerbatimFields().put(DwcTerm.island, "Isla Victoria");
    mockOccurrence.getVerbatimFields().put(DwcTerm.country, "USA");
    mockOccurrence.getVerbatimFields().put(DwcTerm.countryCode, "AR");
    mockOccurrence.getVerbatimFields().put(DwcTerm.stateProvince, "California");
    mockOccurrence.getVerbatimFields().put(DwcTerm.county, "Los Lagos");
    mockOccurrence.getVerbatimFields().put(DwcTerm.municipality, "Holzminden");
    mockOccurrence.getVerbatimFields().put(DwcTerm.locality, "Bariloche, 25 km NNE via Ruta Nacional 40 (=Ruta 237)");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimLocality, "25 km NNE Bariloche por R. Nac. 237");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimElevation, "100-200 m");
    mockOccurrence.getVerbatimFields().put(DwcTerm.minimumElevationInMeters, "100");
    mockOccurrence.getVerbatimFields().put(DwcTerm.maximumElevationInMeters, "200");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimDepth, "100-200 m");
    mockOccurrence.getVerbatimFields().put(DwcTerm.minimumDepthInMeters, "100");
    mockOccurrence.getVerbatimFields().put(DwcTerm.maximumDepthInMeters, "200");
    mockOccurrence.getVerbatimFields().put(DwcTerm.minimumDistanceAboveSurfaceInMeters, "0");
    mockOccurrence.getVerbatimFields().put(DwcTerm.maximumDistanceAboveSurfaceInMeters, "-1.5");
    mockOccurrence.getVerbatimFields().put(DwcTerm.locationAccordingTo, "Getty Thesaurus of Geographic Names");
    mockOccurrence.getVerbatimFields().put(DwcTerm.locationRemarks, "Under water since 2005");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimCoordinates, "41 05 54S 121 05 34W");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimLatitude, "41 05 54.03S");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimLongitude, "121d 10 34 W");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimCoordinateSystem, "decimal degrees");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimSRS, "EPSG:4326");
    mockOccurrence.getVerbatimFields().put(DwcTerm.decimalLatitude, "-41.0983423");
    mockOccurrence.getVerbatimFields().put(DwcTerm.decimalLongitude, "-121.1761111");
    mockOccurrence.getVerbatimFields().put(DwcTerm.geodeticDatum, "WGS84");
    mockOccurrence.getVerbatimFields().put(DwcTerm.coordinateUncertaintyInMeters, "30");
    mockOccurrence.getVerbatimFields().put(DwcTerm.coordinatePrecision, "0.00001");
    mockOccurrence.getVerbatimFields().put(DwcTerm.pointRadiusSpatialFit, "1");
    mockOccurrence.getVerbatimFields().put(DwcTerm.footprintWKT, "POLYGON ((10 20, 11 20, 11 21, 10 21, 10 20))");
    mockOccurrence.getVerbatimFields().put(DwcTerm.footprintSRS, "PRIMEM[Greenwich,0]");
    mockOccurrence.getVerbatimFields().put(DwcTerm.footprintSpatialFit, "1");
    mockOccurrence.getVerbatimFields().put(DwcTerm.georeferencedBy, "Kristina Yamamoto (MVZ)");
    mockOccurrence.getVerbatimFields().put(DwcTerm.georeferencedDate, "1963-03-08T14:07-0600");
    mockOccurrence.getVerbatimFields().put(DwcTerm.georeferenceProtocol, "Georeferencing Quick Reference Guide");
    mockOccurrence.getVerbatimFields().put(DwcTerm.georeferenceSources, "USGS 1:24000 Florence Montana Quad");
    mockOccurrence.getVerbatimFields().put(DwcTerm.georeferenceVerificationStatus, "Requires verification");
    mockOccurrence.getVerbatimFields().put(DwcTerm.geologicalContextID, "stratigraphy:1");
  }

  /**
   * Populate all geological concept terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_GEOLOGICALCONTEXT
   */
  private static void populateVerbatimDwcGeologicalConceptTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.geologicalContextID, "stratigraphy:1");
    mockOccurrence.getVerbatimFields().put(DwcTerm.earliestEonOrLowestEonothem, "Phanerozoic");
    mockOccurrence.getVerbatimFields().put(DwcTerm.latestEonOrHighestEonothem, "Proterozoic");
    mockOccurrence.getVerbatimFields().put(DwcTerm.earliestEraOrLowestErathem, "Cenozoic");
    mockOccurrence.getVerbatimFields().put(DwcTerm.latestEraOrHighestErathem, "Mesozoic");
    mockOccurrence.getVerbatimFields().put(DwcTerm.earliestPeriodOrLowestSystem, "Neogene");
    mockOccurrence.getVerbatimFields().put(DwcTerm.latestPeriodOrHighestSystem, "Quaternary");
    mockOccurrence.getVerbatimFields().put(DwcTerm.earliestEpochOrLowestSeries, "Ibexian Series");
    mockOccurrence.getVerbatimFields().put(DwcTerm.latestEpochOrHighestSeries, "Pleistocene");
    mockOccurrence.getVerbatimFields().put(DwcTerm.earliestAgeOrLowestStage, "Skullrockian");
    mockOccurrence.getVerbatimFields().put(DwcTerm.latestAgeOrHighestStage, "Boreal");
    mockOccurrence.getVerbatimFields().put(DwcTerm.lowestBiostratigraphicZone, "N. Atlantic Conodont");
    mockOccurrence.getVerbatimFields().put(DwcTerm.highestBiostratigraphicZone, "Midcontinent Condonot");
    mockOccurrence.getVerbatimFields().put(DwcTerm.lithostratigraphicTerms, "shale lithosome");
    mockOccurrence.getVerbatimFields().put(DwcTerm.group, "Lithosome");
    mockOccurrence.getVerbatimFields().put(DwcTerm.formation, "House Limestone");
    mockOccurrence.getVerbatimFields().put(DwcTerm.member, "Hellnmaria Member");
    mockOccurrence.getVerbatimFields().put(DwcTerm.bed, "hiatus");
  }


  /**
   * Populate all identification terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_IDENTIFICATION
   */
  private static void populateVerbatimDwcIdentificationTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.identificationID, "ID_ID:2");
    mockOccurrence.getVerbatimFields().put(DwcTerm.identifiedBy, "John Smith");
    mockOccurrence.getVerbatimFields().put(DwcTerm.dateIdentified, "1963-03-08T14:07-0600");
    mockOccurrence.getVerbatimFields().put(DwcTerm.identificationReferences, "Aves del Patagonico. Christie et al. 2004.");
    mockOccurrence.getVerbatimFields().put(DwcTerm.identificationVerificationStatus, "4");
    mockOccurrence.getVerbatimFields().put(DwcTerm.identificationRemarks, "Distinguished on the lengths of the uñas.");
    mockOccurrence.getVerbatimFields().put(DwcTerm.identificationQualifier, "aff. agrifolia var. oxyadenia");
    mockOccurrence.getVerbatimFields().put(DwcTerm.typeStatus, "holotype of Ctenomys sociabilis. Pearson O. P.");
  }

  /**
   * Populate all taxon terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_TAXON
   */
  private static void populateVerbatimDwcTaxonTerms() {
    mockOccurrence.getVerbatimFields().put(DwcTerm.taxonID, "8fa58e08-08de-4ac1-b69c-1235340b7001");
    mockOccurrence.getVerbatimFields().put(DwcTerm.scientificNameID, "urn:lsid:ipni.org:names:37829-1:1.3");
    mockOccurrence.getVerbatimFields().put(DwcTerm.acceptedNameUsageID , "8fa58e08-08de-4ac1-b69c-1235340b7001");
    mockOccurrence.getVerbatimFields().put(DwcTerm.parentNameUsageID, "8fa58e08-08de-4ac1-b69c-1235340b7001");
    mockOccurrence.getVerbatimFields().put(DwcTerm.originalNameUsageID, "http://species.gbif.org/1753");
    mockOccurrence.getVerbatimFields().put(DwcTerm.nameAccordingToID, "doi:10.1016/S0269-915X(97)80026-2");
    mockOccurrence.getVerbatimFields().put(DwcTerm.namePublishedInID, "http://hdl.handle.net/10199/7");
    mockOccurrence.getVerbatimFields().put(DwcTerm.taxonConceptID, "http://hdl.handle.net/10199/7");
    mockOccurrence.getVerbatimFields().put(DwcTerm.scientificName, "Caracara cheriway");
    mockOccurrence.getVerbatimFields().put(DwcTerm.acceptedNameUsage, "Caracara cheriway, Jacquin, 1784");
    mockOccurrence.getVerbatimFields().put(DwcTerm.parentNameUsage, "Caracara");
    mockOccurrence.getVerbatimFields().put(DwcTerm.originalNameUsage, "Caracara cheriway");
    mockOccurrence.getVerbatimFields().put(DwcTerm.nameAccordingTo, "Werner Greuter 2008");
    mockOccurrence.getVerbatimFields().put(DwcTerm.namePublishedIn, "Pearson O. P. 1985. Historia Natural, 5(37):388");
    mockOccurrence.getVerbatimFields().put(DwcTerm.namePublishedInYear, "1985");
    mockOccurrence.getVerbatimFields().put(DwcTerm.higherClassification, "Animalia;Chordata;Aves;Falconiformes;Falconidae");
    mockOccurrence.getVerbatimFields().put(DwcTerm.kingdom, "Animalia");
    mockOccurrence.getVerbatimFields().put(DwcTerm.phylum, "Chordata");
    mockOccurrence.getVerbatimFields().put(DwcTerm.class_, "Aves");
    mockOccurrence.getVerbatimFields().put(DwcTerm.order, "Falconiformes");
    mockOccurrence.getVerbatimFields().put(DwcTerm.family, "Falconidae");
    mockOccurrence.getVerbatimFields().put(DwcTerm.genus, "Caracara");
    mockOccurrence.getVerbatimFields().put(DwcTerm.subgenus, "Caracara");
    mockOccurrence.getVerbatimFields().put(DwcTerm.specificEpithet, "cheriway");
    mockOccurrence.getVerbatimFields().put(DwcTerm.infraspecificEpithet, "cheriway");
    mockOccurrence.getVerbatimFields().put(DwcTerm.taxonRank, "species");
    mockOccurrence.getVerbatimFields().put(DwcTerm.verbatimTaxonRank, "sp.");
    mockOccurrence.getVerbatimFields().put(DwcTerm.scientificNameAuthorship, "Jacquin, 1784");
    mockOccurrence.getVerbatimFields().put(DwcTerm.vernacularName, "American Eagle");
    mockOccurrence.getVerbatimFields().put(DwcTerm.nomenclaturalCode, "ICBN");
    mockOccurrence.getVerbatimFields().put(DwcTerm.taxonomicStatus, "accepted");
    mockOccurrence.getVerbatimFields().put(DwcTerm.nomenclaturalStatus, "nom. ambig.");
    mockOccurrence.getVerbatimFields().put(DwcTerm.taxonRemarks, "this name is a misspelling in common use");
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
    try {
      MediaObject media = new MediaObject();
      media.setType(MediaType.StillImage);
      media.setFormat("JPEG");
      media.setCreated(new Date());
      media.setIdentifier(
        new URI("http://digit.snm.ku.dk/www/Aves/full/AVES-100348_Caprimulgus_pectoralis_fervidus_ad____f.jpg"));
      media.setLicense("CC-BY-NC");
      media.setReferences(new URI("http://www.multimedia.danbif.dk/Animalia/chordata/aves/caprimulgiformes/caprimulgidae/caprimulgus/pectoralis"));
      media.setPublisher("DanBIF");
      media.setContributor("Christian Rassmussen");
      media.setRightsHolder("Danske Bank");
      media.setAudience("Academia");
      media.setSource("Hans Christian Andersen, De vilde Svaner");
      media.setTitle("Pectoralis");
      mockOccurrence.getMedia().add(media);

      media = new MediaObject();
      media.setType(MediaType.StillImage);
      media.setCreated(new Date());
      media.setCreator("G. U. Skinner");
      media.setDescription("Polypodium skinneri Hook sheet");
      media.setIdentifier(new URI("http://ww2.bgbm.org/herbarium/images/B/20/00/76/52/thumbs/b_20_0076524.jpg"));
      media.setLicense("Image parts provided by this server with the given resolution have been released under the Creative Commons cc-by-sa 3.0 (generic) licence [http://creativecommons.org/licenses/by-sa/3.0/de/]. Please credit images to BGBM following our citation guidelines ");
      media.setReferences(new URI("http://search.biocase.org/edit/search/units/details/getDetails/B%2020%200076524/Herbarium%20Berolinense/BGBM/1095"));
      media.setPublisher("Botanic Garden and Botanical Museum Berlin-Dahlem");
      media.setTitle("Polypodium skinneri");

      mockOccurrence.getMedia().add(media);
      media = new MediaObject();
      media.setType(MediaType.MovingImage);
      media.setCreated(new Date());
      media.setCreator("M. Döring");
      media.setDescription("A very young looking biologist");
      media.setLicense("CC0");
      media.setReferences(new URI("https://www.youtube.com/watch?v=DVN65nmoEHk"));
      media.setPublisher("banddelux");
      media.setTitle("CELLOPHANE SUCKERS - This is Rock`n`Roll (The Kids)");
      mockOccurrence.getMedia().add(media);

      media = new MediaObject();
      media.setType(MediaType.Sound);
      media.setCreator("M. Döring");
      media.setLicense("CC0");
      media.setIdentifier(new URI("https://www.youtube.com/watch?v=DVN65nmoEHk"));
      media.setReferences(new URI("https://www.youtube.com/watch?v=DVN65nmoEHk"));
      media.setPublisher("banddelux");
      media.setTitle("Audio - This is Rock`n`Roll (The Kids)");
      mockOccurrence.getMedia().add(media);

      mockOccurrence.getMedia().add(media);

    } catch (URISyntaxException e) {
      // not possible
      throw Throwables.propagate(e);
    }
  }

  private static void populateVerbatimExtensions() {
    List<Map<Term, String>> media = Lists.newArrayList();
    mockOccurrence.getExtensions().put(Extension.IMAGE, media);

    Map<Term, String> obj = Maps.newHashMap();
    obj.put(DcTerm.identifier, "http://farm8.staticflickr.com/7093/7039524065_3ed0382368.jpg");
    obj.put(DcTerm.references, "http://www.flickr.com/photos/70939559@N02/7039524065");
    obj.put(DcTerm.format, "jpg");
    obj.put(DcTerm.title, "Geranium Plume Moth 0032");
    obj.put(DcTerm.description, "Geranium Plume Moth 0032 description");
    obj.put(DcTerm.license, "BY-NC-SA 2.0");
    obj.put(DcTerm.creator, "Moayed Bahajjaj");
    obj.put(DcTerm.created, "2012-03-29");
    media.add(obj);

    obj = Maps.newHashMap();
    obj.put(DcTerm.identifier, "http://none.staticflickr.com/666.png");
    obj.put(DcTerm.references, "http://none.staticflickr.com/666");
    obj.put(DcTerm.title, "Babe at the beach");
    obj.put(DcTerm.license, "CC0");
    obj.put(DcTerm.creator, "Rod Steward");
    obj.put(DcTerm.created, "1968-02-19");
    media.add(obj);

    List<Map<Term, String>> facts = Lists.newArrayList();
    mockOccurrence.getExtensions().put(Extension.MEASUREMENT_OR_FACT, facts);

    obj = Maps.newHashMap();
    obj.put(DwcTerm.measurementType, "sound intensity");
    obj.put(DwcTerm.measurementValue, "128");
    obj.put(DwcTerm.measurementUnit, "Decibel");
    obj.put(DwcTerm.measurementDeterminedDate, "1966");
    obj.put(DwcTerm.measurementDeterminedBy, "Ron Wood");
    facts.add(obj);
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
